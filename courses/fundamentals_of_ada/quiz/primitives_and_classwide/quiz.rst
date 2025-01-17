.. code:: Ada

    type T1 is tagged null record;
    type T2 is new T1 with null record;
    -- Declarations
    V : T2;

Which of the following piece(s) of code allow for calling :ada:`Proc (V)`?

A. ``procedure Proc (V : T1) is null``
B. :answermono:`procedure Proc (V : T1'Class) is null`
C. | ``procedure Proc (V : T1'Class) is null;``
   | ``procedure Proc (V : T2'Class) is null;``
D. :answermono:`procedure Proc (V : T2) is null`

.. container:: animate

    A. Declared in the scope of T1, **after** T1 is frozen: illegal for :ada:`tagged` types
    B. Correct, but not a primitive
    C. :ada:`T1'Class` contains :ada:`T2'Class`
    D. Proc is a primitive of T2 **only**
