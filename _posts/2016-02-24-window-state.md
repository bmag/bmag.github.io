---
title: Structure of Window State Objects
layout: post
date: 2016-02-24
---
* TOC
{:toc}

## Intro

Window state objects were first introduced in Emacs 24.1, as a way to save and
restore window layouts. They are an alternative to the older window
configuration objects, which are also used to save and restore window layouts.
You can read about both of them in the [manual][1].

To create a window state object, you call the function `window-state-get`.
Later, when you want to restore the window layout, you pass thet window state
object to `window-state-put`.

One of the advantages of window states over window configurations, is that
window states are regular lisp objects, not opaque C objects, unlike window
configurations. The advantage here is that they can be serilized, saved to
file and read from file. Effectively, you can save a window state in one Emacs
session, and load it in another session[^1].

However, despite the fact that window states are lisp objects, I could find no
tools to analyse them and no documentation about their structure. So I decided
to dive into the code, research, and document. My findings are detailed below.

## The Source

I have used Emacs 24.5 for the research. The relevant code is contained in
file `lisp/window.el`, from [line 4843][2] to [line 5238][3].

## Structure of a Window State

{% highlight emacs-lisp %}
(header ;; minimal sizes
 window ;; root window
 )
{% endhighlight %}
  
A window state object contains a header, and a root window. The header
specifies minimal sizes that any window is allowed to have.

Any window in a window state object, including the root window, can contain
child windows. Meaning that window state objects have a tree-like structure.

Note that in this article, a "window object" refers to the representation of a
window in a window state object, not real window objects recognized by the
function `windowp`.

## Header

{% highlight emacs-lisp %}
((min-height . <integer>)
 (min-width . <integer>)
 (min-height-ignore . <integer>)
 (min-width-ignore . <integer>)
 (min-height-safe . <integer>)
 (min-width-safe . <integer>)
 (min-pixel-height . <integer>)
 (min-pixel-width . <integer>)
 (min-pixel-height-ignore . <integer>)
 (min-pixel-width-ignore . <integer>)
 (min-pixel-height-safe . <integer>)
 (min-pixel-width-safe . <integer>))
{% endhighlight %}

The header is an [alist][4] of minimal window sizes.

## Window

Basic structure of a window object:
{% highlight emacs-lisp %}
(<split-type> . <alist-of-window-properties>)
{% endhighlight %}

`split-type` can have three possible values:

- `leaf`: the window has no children. It contains a buffer and corresponds to a
  live window.
- `hc`: the window is a parent window. It is split horizontally, contains child
  windows and has no buffer.
- `vc`: same as `hc`, but the window is split vertically instead of
  horizontally.
    
### Parent Window

Structure of a parent window:
{% highlight emacs-lisp %}
;; window that is split horizontally to several windows
(hc ;; leaf - no split, hc - horizontal split, vc - vertical split
 ;; the rest is an alist, accessed as an alist, the order doesn't matter as long
 ;; as the windows are at the end
 (last . t) ;; optional entry, only exists for last window in sublist
 ;; sizes - it isn't clear if all of these entries have to exist
 (pixel-width . 1855)
 (pixel-height . 1039)
 (total-width . 232)
 (total-height . 61)
 (normal-height . 1.0)
 (normal-width . 1.0)
 (combination-limit . <?>)
 ;; if WRITABLE (a parameter passed to `window-state-get') is t, saved paramters
 ;; are controlled by `window-persistent-parameters'
 (parameters . <alist-of-window-parameters>)
 <window1>
 <window2>
 ;; ... (more windows, the last one has a (last . t) entry)
 )
{% endhighlight %}
  
`<alist-of-window-parameters>` is a collection of window paramters that can be
set by the function `set-window-parameter`.

### Leaf Window

Structure of a leaf window:
{% highlight emacs-lisp %}
;; unsplit window (live window, contains a buffer)
(leaf
 ;; the rest is an alist, accessed as an alist, the order doesn't matter as long
 ;; as the windows are at the end
 (last . t) ;; optional entry, only exists for last window in sublist
 ;; sizes - it isn't clear if all of these entries have to exist
 (pixel-width . 1855)
 (pixel-height . 1039)
 (total-width . 232)
 (total-height . 61)
 (normal-height . 1.0)
 (normal-width . 1.0)
 (combination-limit . <?>)
 ;; if WRITABLE (a parameter passed to `window-state-get') is t, saved paramters
 ;; are controlled by `window-persistent-parameters'
 (parameters . <alist-of-window-parameters>)
 (buffer . <buffer-object>))
{% endhighlight %}

## Buffer
{% highlight emacs-lisp %}
;; basic structure:
(<buffer-nam> . <alist-of-buffer-properties>)

;; detailed:
("window.el" ;; name
 ;; the rest is an alist
 (selected) ;; true for selected buffer (that's how they know what WINDOW was selected?)
 (hscroll . 0)
 (fringes 8 8 nil)
 (margins nil)
 (scroll-bars 0 0 t nil)
 (vscroll . 0)
 (dedicated)
 ;; uses numbers instead of markers if WRITABLE is t
 (point . <a marker>)
 (start . <a marker>))
{% endhighlight %}

## Examples of Window State Objects

### Single Window

Example of a single window, showing an `ielm`[^2] buffer:
{% highlight emacs-lisp %}
(((min-height . 4)
  (min-width . 10)
  (min-height-ignore . 4)
  (min-width-ignore . 4)
  (min-height-safe . 1)
  (min-width-safe . 2)
  (min-pixel-height . 68)
  (min-pixel-width . 80)
  (min-pixel-height-ignore . 68)
  (min-pixel-width-ignore . 32)
  (min-pixel-height-safe . 17)
  (min-pixel-width-safe . 16))
 leaf
 (last . t)
 (pixel-width . 928)
 (pixel-height . 1039)
 (total-width . 116)
 (total-height . 61)
 (normal-height . 1.0)
 (normal-width . 0.5)
 (parameters
  (clone-of . #<window 6 on *ielm*>))
 (buffer "*ielm*"
         (selected . t)
         (hscroll . 0)
         (fringes 8 8 nil)
         (margins nil)
         (scroll-bars 0 0 t nil)
         (vscroll . 0)
         (dedicated)
         (point . #<marker
                (moves after insertion)
                at 1715 in *ielm*>)
         (start . #<marker at 271 in *ielm*>)))
{% endhighlight %}

### Multiple Windows

Example of three windows arranged in one horizontal split and one vertical
split. Left window showing an elisp file, top-right window showing an `ielm`
buffer, and bottom-right window showing a help buffer:

{% highlight emacs-lisp %}
;; window state object for 3 windows in this layout:
;; +---------+----------+
;; |         |          |
;; |         |          |
;; |         |          |
;; |         +----------+
;; |         |          |
;; +---------+----------+
(((min-height . 8)
  (min-width . 20)
  (min-height-ignore . 6)
  (min-width-ignore . 8)
  (min-height-safe . 2)
  (min-width-safe . 4)
  (min-pixel-height . 136)
  (min-pixel-width . 160)
  (min-pixel-height-ignore . 102)
  (min-pixel-width-ignore . 64)
  (min-pixel-height-safe . 34)
  (min-pixel-width-safe . 32))
 hc
 (pixel-width . 1855)
 (pixel-height . 1039)
 (total-width . 232)
 (total-height . 61)
 (normal-height . 1.0)
 (normal-width . 1.0)
 (combination-limit)
 (parameters
  (clone-of . #<window 59>))
 (leaf
  (pixel-width . 927)
  (pixel-height . 1039)
  (total-width . 116)
  (total-height . 61)
  (normal-height . 1.0)
  (normal-width . 0.5)
  (parameters
   (clone-of . #<window 682 on windowx.el>)
   (purpose-dedicated . t))
  (buffer "windowx.el"
          (selected)
          (hscroll . 0)
          (fringes 8 8 nil)
          (margins nil)
          (scroll-bars 0 0 t nil)
          (vscroll . 0)
          (dedicated)
          (point . #<marker at 4420 in *ielm*>)
          (start . #<marker at 3593 in *ielm*>)))
 (vc
  (last . t)
  (pixel-width . 928)
  (pixel-height . 1039)
  (total-width . 116)
  (total-height . 61)
  (normal-height . 1.0)
  (normal-width . 0.5)
  (combination-limit)
  (parameters
   (clone-of . #<window 703>))
  (leaf
   (pixel-width . 928)
   (pixel-height . 706)
   (total-width . 116)
   (total-height . 41)
   (normal-height . 0.6799807507218478)
   (normal-width . 1.0)
   (parameters
    (clone-of . #<window 60 on *ielm*>)
    (purpose-dedicated))
   (buffer "*ielm*"
           (selected . t)
           (hscroll . 0)
           (fringes 8 8 nil)
           (margins nil)
           (scroll-bars 0 0 t nil)
           (vscroll . 0)
           (dedicated)
           (point . #<marker
                  (moves after insertion)
                  at 33251 in *ielm*>)
           (start . #<marker at 12314 in *ielm*>)))
  (leaf
   (last . t)
   (pixel-width . 928)
   (pixel-height . 333)
   (total-width . 116)
   (total-height . 20)
   (normal-height . 0.3200192492781521)
   (normal-width . 1.0)
   (parameters
    (clone-of . #<window 704 on *Help*>)
    (purpose-dedicated))
   (buffer "*Help*"
           (selected)
           (hscroll . 0)
           (fringes 8 8 nil)
           (margins nil)
           (scroll-bars 0 0 t nil)
           (vscroll . 0)
           (dedicated)
           (point . #<marker at 200 in *ielm*>)
           (start . #<marker at 1 in *ielm*>)))))
{% endhighlight %}

## Sample Code

### Analysing Window State Objects

{% highlight emacs-lisp %}
(require 'seq)

(defun window-state-window-p (object)
  "Return t if OBJECT is a window, as represented in window-state objects.
Note: this function doesn't test for real window objects, but for
representations of a window in a window-state object as returned by
`window-state-get'."
  (and (listp object)
       (memq (car object) '(leaf vc hc))))

(defun window-state-get-buffer (window)
  "Get WINDOW's buffer.
WINDOW is the representation of a window in a window-state object.
The returned value is the representation of a buffer in a window-state
object."
  (cdr (assq 'buffer window)))

(defun window-state-get-buffer-name (window)
  "Get WINDOW's buffer's name.
WINDOW is the representation of a window in a window-state object."
  (car (window-state-get-buffer window)))

(defun window-state-walk-windows-1 (window fn)
  "Helper function for `window-state-walk-windows'."
  (let ((child-windows
         (seq-filter #'window-state-window-p window))
        (bare-window
         ;; if WINDOW contains more than one window, take only the first window
         (seq-take-while (lambda (item)
                           (not (window-state-window-p item)))
                         window)))
    (mapc (lambda (win)
            (window-state-walk-windows-1 win fn))
          child-windows)
    (push (funcall fn bare-window) result)))

(defun window-state-walk-windows (state fn)
  "Execute FN once for each window in STATE and make a list of the results.
FN is a function to execute.
STATE is a window-state object."
  (let (result)
    (window-state-walk-windows-1 (cdr state) fn)
    result))

(defun window-state-all-windows (state)
  "Get all windows contained in STATE.
STATE is a window-state object.
The returned windows are not actual window objects. They are windows as
represented in window-state objects."
  (window-state-walk-windows state #'identity))

(defun window-state-get-buffer-names (state)
  "Get names of all buffers saved in STATE.
STATE is a window-state object as returned by `window-state-get'."
  (delq nil (window-state-walk-windows state #'window-state-get-buffer-name)))

(defun window-state-get-buffers (state)
  "Get all buffers saved in STATE.
STATE is a window-state object as returned by `window-state-get'."
  ;; delq nil - removes buffers stored in STATE that don't exist anymore
  (delq nil (mapcar #'get-buffer (window-state-get-buffer-names state))))
{% endhighlight %}

### Usage: Open Buffer in Workspace (Eyebrowse)

Eyebrowse is a package for switching between existing window layouts. By
default, the layouts are stored as window state objects. By leveraging the
code above, we can write a command to switch to a buffer in a workspace that
already contains that buffer.

{% highlight emacs-lisp %}
(defun find-buffer-workspace (buffer)
  "Find Eyebrowse workspace containing BUFFER.
If several workspaces contain BUFFER, return the first one. Workspaces are
ordered by slot number.
If no workspace contains
BUFFER, return nil."
  ;; the second element of a workspace is its window-state object
  (seq-find (lambda (workspace)
              (memq buffer
                    (window-state-get-buffers (cadr workspace))))
            (eyebrowse--get 'window-configs)))

(defun display-buffer-in-workspace (buffer alist)
  "Display BUFFER's workspace.
Return BUFFER's window, if exists, otherwise nil.
If BUFFER is already visible in current workspace, just return its window
without switching workspaces."
  (or (get-buffer-window buffer)
      (let ((workspace (find-buffer-workspace buffer)))
        (when workspace
          (eyebrowse-switch-to-window-config (car workspace))
          (get-buffer-window buffer)))))

(defun goto-buffer-workspace (buffer)
  "Switch to BUFFER's window in BUFFER's workspace.
If BUFFER isn't displayed in any workspace, display it in the current
workspace, preferably in the current window."
  (interactive "B")
  (pop-to-buffer buffer '(( ;; reuse buffer window from some workspace
                           display-buffer-in-workspace
                           ;; fallback to display in current window
                           display-buffer-same-window)
                          (inhibit-same-window . nil))))
{% endhighlight %}



[^1]:
    You still need somehow to restore the actual buffers - window states don't
    restore buffers that don't exist

[^2]: ielm is an elisp REPL

[1]: https://www.gnu.org/software/emacs/manual/html_node/elisp/Window-Configurations.html#Window-Configurations
[2]: http://git.savannah.gnu.org/cgit/emacs.git/tree/lisp/window.el?id=emacs-24.5#n4843
[3]: http://git.savannah.gnu.org/cgit/emacs.git/tree/lisp/window.el?id=emacs-24.5#n5238
[4]: https://www.gnu.org/software/emacs/manual/html_node/elisp/Association-Lists.html
