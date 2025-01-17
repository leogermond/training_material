:title: CodePeer - Tutorial
:subtitle: Running and filtering with :toolname:`GNAT Studio`

.. highlight:: Ada

****************
Running CodePeer
****************

* Select the menu :menuselection:`CodePeer -> Analyze All` in the menu bar at the top.

.. image:: codepeer/menu_analyze_all.png

This will run :toolname:`CodePeer`, which first generates SCIL files, then runs
the CodePeer engine itself, and finally displays a summary of the problems
found in the CodePeer report window.

Here, CodePeer reports a few medium and low messages, and displays only the medium ones.

.. image:: codepeer/tutorial_report.png

.. image:: codepeer/tutorial_messages_medium.png

Notice the different kinds of filters that are available on the right side of
the window. Clicking on each of these filters will show/hide the corresponding
messages in the locations view at the bottom.

* Uncheck the box **medium** in Message ranking.

This clears the location view.

* Check the box **low** in Message ranking.

The location view now reports the low messages only.

.. image:: codepeer/tutorial_messages_low.png

* Undo these changes to recover medium messages only.

During all these changes,
the CodePeer report window was not affected as it reports all problems found.
The filters only apply to the locations view.

**********************
Understanding Messages
**********************

Checks
======

* In the location view, click in the tree on the `+` sign (or triangle) at the left of :file:`tokens.adb`.

* Click on the message reported at line 26. This opens the file :file:`tokens.adb` at line 26.

.. image:: codepeer/tutorial_l26_location.png

.. image:: codepeer/tutorial_l26_code.png

The message gives 3 different pieces of information:

* Ranking

  Can be **high**, **medium** or **low**. It is an indication of the
  severity and certainty of the associated message.  The higher the
  ranking, the more interesting the message, and the greater the
  likelihood the indicated line of code would fail when executed.

  Here, it is a **low** gravity message.

* Check

  A short description of the problem.

  Here, it says that the array index check might fail.

* Explanation

  Some messages have a more detailed explanation to help you understand
  the problem.

  Here, it says that it requires the first index in
  `Input.Next_Word` to be less than its last index, which is the
  same as saying `Input.Next_Word` should not be empty.

Indeed, the expression at line 26 is accessing at the first index in local
variable `Word`, which happens to be initialized at line 18 with a call to
`Input.Next_Word`. So it will raise a `Constraint_Error` if `Input.Next_Word`
returns the empty string.

* Go to the definition of function `Input.Next_Word`.

This can be achieved either by clicking on the right mouse button on `Next_Word` on line 18 and
selecting `Goto body of Next_Word` or by clicking on the middle mouse button
while holding :kbd:`Control` key and moving the mouse over `Next_Word` on line 18.
To do so, you first need to go to `Scenario` and in the `Build Mode`, select
`codepeer` from the drop down list.

The annotations generated by CodePeer are displayed before the definition of
function `Next_Word` on line 184.

.. image:: codepeer/tutorial_next_word_annotations.png

* Hide these annotations by clicking on the right mouse button and selecting :menuselection:`CodePeer -> Hide annotations`.

.. image:: codepeer/tutorial_next_word_hide_annotations.png
    :width: 50%

* Re-display these annotations by clicking on the right mouse button and selecting :menuselection:`CodePeer -> Show annotations`.

In the postconditions generated by CodePeer, you can see that CodePeer computed
a possible range of `1..1_024` for the application of attribute `First` to the
result of calling `Next_Word`, which is displayed as
`input.next_word'Result'First`, and a possible range of `0..1_023` for the
application of attribute `Last` to the same value. This includes the case where
`Result'First` is 1 and `Result'Last` is 0, so the result may be an empty
string.

Looking at the body of function `Next_Word`, it appears that an empty string is
indeed returned when the first character read on line
191 is not in the range of `Printable_Character`.

* To protect against this error, return to file :file:`tokens.adb` at line 26
* Insert the following code before the case-statement::

              if Word = "" then
                 raise Except.User_Error;
              end if;

* Re-run CodePeer by selecting the menu :menuselection:`CodePeer -> Analyze All`.
* Notice that the error on :file:`tokens.adb` has disappeared.

Warnings
========

This refers to messages reported by CodePeer that do not correspond to
checks, but rather to potential logic errors: dead code, test or condition
predetermined, unused assignment, etc. Like checks, these messages have an
associated ranking, they are introduced by the keyword **warning** which
is appended after the **high**, **medium** or **low** markers, e.g
**medium warning**.

* In the locations view, click on the message reported at line 41 of :file:`stack.adb`. 

It says that the precondition
computed by CodePeer for variable `Last` is suspicious, because it is not a
continuous range of values.

Indeed, looking at the preconditions generated by CodePeer, we see the
following lines::

     --  Preconditions:
     --    Last in (2..199, 201)


It is indeed the case that the range of values allowed for variable `Last` has
a 'hole', because value 200 is not allowed while values
199 and 201 are allowed.

Since 200 is the value of `Tab'Last`, having `Last` equal to
200 means that the stack is full. So it is expected that we should not call
`Push` on a stack when `Last` equals 200.

What's surprising is that `Last` can be equal to 201 in the precondition
computed by CodePeer. This means that we could call `Push` on a stack which is
more than full!

* Let's simulate what happens when we call `Push` with `Last` being equal to 201.

The test on line 43 is false, so execution continues on line 47, then on line
49 `Last` is assigned the value 200 (201 - 1) and finally on line 50 we replace the last item in array `Tab` with the
value `V`.

* Quick quiz: What is wrong with this piece of code?

The problem is on line 49: instead of decrementing the value of `Last`, it
should be incremented. This bug could also be found by debugging.

Notice that it also causes the message at line 11 in file :file:`values.adb`,
because function `Stack.Push` is called in function `Values.Process`, so the
precondition generated for `Stack.Push` causes a similar precondition to be
generated for `Values.Process`.

This kind of logic error typically results in a precondition with a 'hole' like
the one reported here. This is why CodePeer reports warnings when it encounters
such preconditions.

* Correct the faulty line
* Re-run CodePeer.

The two messages in files :file:`stack.adb` and :file:`values.adb` should no longer be present.

False Positive
==============

Some messages reported by CodePeer are not actual errors. These messages which
are called *false positive* are a necessary evil when performing static
analysis of complex properties of code.

* Allow low messages to be displayed by checking the box **low** in Message ranking.

* In the location view, click on the message reported on the code you were asked to insert before line 26 of :file:`tokens.adb`.

It says that an exception might
be raised, which is precisely the intention of the inserted code when
`Input.Next_Word` returns an empty string.

* Click on the message reported at line 191 of :file:`input.adb`.

It says that `First_Char` might be greater than `Line_Size` (1024).

This cannot happen, as the call to `Input.Skip_Spaces` ensures that
`First_Char` points within the bounds of `Line` to a printable character, and
the loop between lines 191 and 193 cannot increase `First_Char` beyond
`Line_Size` because the procedure `Input.Read_New_Line` which updates `Line`
ensures that the line is terminated by a character `ASCII.CR` which is not
printable. So the loop will exit at most when `First_Char` is the index of this
last character.

You can choose to ignore such false positive, or else mark them as reviewed so
that they do not show up in future runs of CodePeer.

* Click on the *Edit* icon displayed in front of CodePeer messages in the locations view.

.. image:: codepeer/tutorial_edit.png

This opens a window where you can enter a manual analysis of the message

.. image:: codepeer/tutorial_edit_window.png

* Change its *New status* to **Not a bug**.

Notice that the reasoning above, for the value of `First_Char`, depends on
subtle invariants maintained by the code on the `Line` data structure. This may
reveal brittle code which would deserve refactoring. A good way to realize this
is to try to understand how `Input.Skip_Spaces` ensures that `First_Char`
points within the bounds of `Line`. This is not as easy as it seems!


*************************
Understanding Annotations
*************************

Basic Annotations
=================

* Open the file :file:`stack.adb` and look at the annotations for procedure `Push`.

The preconditions of `Push` correspond to constraints that should be respected
prior to calling `Push` in order to avoid errors. The third precondition states
that `Last` should be less than 200, so that the stack is not full. The other
preconditions state that parameter `V` should not be null and `V.E` should be
initialized::

     --  Preconditions:
     --    Last <= 199
     --    V /= null
     --    V.E'Initialized

* Quick quiz: Where can this precondition be traced from?

While some preconditions can be traced to checks inside the current procedure,
others originate in functions or procedures directly or indirectly (through a
chain of other functions or procedures) called by the current procedure. Here,
the last precondition can be traced to the increment on `Last` at line 49 and
the access to `Tab (Last)` that follows on line 50, while the preconditions on
`V` are propagated from the precondition of function `Values.To_String` called
on line 47.

The postconditions of `Push` correspond to constraints that will be satisfied
after calling `Push`. The first postcondition states that the output value for
`Last` will be its input value plus one. Notice the use of Ada 2012
attribute `'Old` to denote the input value of `Last`. The second postcondition
states that the output value of `Last` will be in the range 1..200::

     --  Postconditions:
     --    Last = Last'Old + 1
     --    Last in 1..200
     --    Tab(1..200) = One-of{V, Tab(1..200)'Old}

We will explain the last postcondition in the next section.

More Complex Annotations
========================

* Open file :file:`tokens.adb` and look at the preconditions generated for procedure `Process`::

   --  Preconditions:
   --    T.Kind /= Op or Stack'Body.Last in 2..200
   --    T.Kind /= Op or Stack'Body.Tab(Stack'Body.Last - 1) /= null
   --    T.Kind /= Op or Stack'Body.Tab(Stack'Body.Last) /= null
   --    T.Kind /= Op or Stack'Body.Tab(1..200).E'Initialized
   --    T.Kind /= Op or T.Op'Initialized
   --    T.Kind <= Op or Stack'Body.Last <= 200 or T.Instr /= Print
   --    T.Kind <= Op or Stack'Body.Last = 0 or T.Instr /= Print or Stack'Body.Tab(Stack'Body.Last) /= null
   --    T.Kind <= Op or Stack'Body.Last = 0 or T.Instr /= Print or Stack'Body.Tab(1..200).E'Initialized
   --    T.Kind <= Op or T.Instr <= Print
   --    T.Kind >= Op or Stack'Body.Last <= 199
   --    T.Kind >= Op or T.Val /= null
   --    T.Kind >= Op or T.Val.E'Initialized


Some preconditions are disjunctions of cases, like
`T.Kind /= Op or Last in 2..200`. This conditional precondition states that,
either `T.Kind` is different from `Op`, or `Last` must be in the range
`2..200`. This is because the constraint on `Last` comes from a path in
`Process` that is only executed when `T.Kind = Op`, so it does not apply when
`T.Kind /= Op`.

* Look now at the postconditions generated for procedure `Process`::

   --  Postconditions:
   --    Stack'Body.Last = One-of{Stack'Body.Last'Old + 1, Stack'Body.Last'Old - 2, Stack'Body.Last'Old - 1, 0, Stack'Body.Last'Old}
   --    Stack'Body.Last <= 200
   --    Stack'Body.Tab(1..200) = One-of{T.Val, Stack'Body.Tab(1..200)'Old, new Value_Info(in values.operations.process)#1'Address}
   --    new Value_Info(in values.operations.process)#1.<num objects> in 0..1
   --    new Value_Info(in values.operations.process)#1.E'Initialized

Some postconditions of `Process` are of the form `Variable =
One-of{Value1, Value2, ...}`. This indicates that the output value of
`Variable` is either `Value1` or `Value2` or ...
Look in particular at the postcondition of this form for `Last`. CodePeer
computed that the
possible output value for `Last` is either zero, input value of `Last`,
input value of `Last` plus one, input value of `Last` minus one or input value
of `Last` minus two. This postcondition effectively summarizes all the
possible modifications occuring to `Last` in various procedures and functions
called from `Process`.

Be aware that, although annotations are displayed in an Ada-friendly syntax,
they may not be legal Ada, or they may designate something different than in
Ada. For example, there is no way in Ada to specify that a value should be
initialized like suggested by the pseudo-Ada attribute `'Initialized`.
Likewise, it is not valid in Ada to refer to the value of 'any element of an
array' like done in CodePeer annotations using the syntax of an array slice.
