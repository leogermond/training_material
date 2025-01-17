************
Genericity
************

..
    Coding language

.. role:: ada(code)
    :language: Ada

.. role:: C(code)
    :language: C

.. role:: cpp(code)
    :language: C++

..
    Math symbols

.. |rightarrow| replace:: :math:`\rightarrow`
.. |forall| replace:: :math:`\forall`
.. |exists| replace:: :math:`\exists`
.. |equivalent| replace:: :math:`\iff`

..
    Miscellaneous symbols

.. |checkmark| replace:: :math:`\checkmark`

==============
Introduction
==============

-------------------------
The Notion of a Pattern
-------------------------

* Sometimes algorithms can be abstracted from types and subprograms

   .. code:: Ada

      procedure Swap_Int ( Left, Right : in out Integer) is
        V : Integer;
      begin
         V := Left;
         Left := Right;
         Right := V;
      end Swap_Int;

      procedure Swap_Bool (Left, Right : in out Boolean) is
         V : Boolean;
      begin
         V := Left;
         Left := Right;
         Right := V;
      end Swap_Bool;

* It would be nice to extract these properties in some common pattern, and then just replace the parts that need to be replaced

   .. code:: Ada

      procedure Swap (Left, Right : in out (Integer | Boolean)) is
        V : (Integer | Boolean);
      begin
         V := Left;
         Left := Right;
         Right := V;
      end Swap;

--------------------
Solution: Generics
--------------------

* A :dfn:`generic unit` is a unit that does not exist
* It is a pattern based on properties
* The instantiation applies the pattern to certain parameters

--------------------------------------
Ada Generic Compared to C++ Template
--------------------------------------

.. container:: columns

 .. container:: column

   * Ada Generic

   .. code:: Ada

      -- specification
      generic
      type T is private;
      procedure Swap
        (L, R : in out T);
      -- implementation
      procedure Swap
        (L, R : in out T) is
         Tmp : T := L
      begin
         L := R;
         R := Tmp;
      end Swap;
      -- instance
      procedure Swap_F is new Swap (Float);

 .. container:: column

   * C++ Template

   .. code:: C++

      template <class T>
      void Swap (T & L, T & R);
      template <class T>
      void Swap (T & L, T & R) {
         T Tmp = L;
         L = R;
         R = Tmp;
      }

.

===================
Creating Generics
===================

---------------------------
What Can Be Made Generic?
---------------------------

* Subprograms and packages can be made generic

   .. code:: Ada

      generic
         type T is private;
      procedure Swap (L, R : in out T)
      generic
         type T is private;
      package Stack is
         procedure Push ( Item : T );
         ...

* Children of generic units have to be generic themselves

   .. code:: Ada

      generic
      package Stack.Utilities is
         procedure Print is

---------------------------
How Do You Use A Generic?
---------------------------

* Generic instantiation is creating new set of data where a generic package contains library-level variables:

.. code:: Ada

   package Integer_stack is new Stack ( Integer );
   package Integer_Stack_Utils is
       new Integer_Stack.Utilities;
   ...
   Integer_Stack.Push ( 1 );
   Integer_Stack_Utils.Print;

==============
Generic Data
==============

----------
Examples
----------

.. include:: examples/160_genericity/generic_data.rst

:url:`https://learn.adacore.com/training_examples/fundamentals_of_ada/160_genericity.html#generic-data`

--------------------------------
Generic Types Parameters (1/2)
--------------------------------

* A generic parameter is a template
* It specifies the properties the generic body can rely on

   .. code:: Ada

      generic
         type T1 is private; -- should have properties
                             -- of private type (assignment,
                             -- comparison, able to declare
                             -- variables on the stack...)
         type T2 (<>) is private;    -- can be unconstrained
         type T3 is limited private; -- can be limited
      package Parent is [...]

* The actual parameter must provide at least as many properties as the :dfn:`generic contract`

--------------------------------
Generic Types Parameters (2/2)
--------------------------------

* The usage in the generic has to follow the contract

.. code:: Ada

   generic
      type T (<>) is private;
   procedure P (V : T);
   procedure P (V : T) is
      X1 : T := V; -- OK, can constrain by initialization
      X2 : T;      -- Compilation error, no constraint to this
   begin
   ...
   type L_T is limited null record;
   ...
   -- unconstrained types are accepted
   procedure P1 is new P (String);
   -- type is already constrained
   procedure P2 is new P (Integer);
   -- Illegal: the type can't be limited because the generic
   -- is allowed to make copies
   procedure P3 is new P (L_T);

---------------------------------------
Possible Properties for Generic Types
---------------------------------------

.. code:: Ada

   type T1 is (<>); -- discrete
   type T2 is range <>; -- integer
   type T3 is digits <>; -- float
   type T4 (<>); -- indefinite
   type T5 is tagged;
   type T6 is array ( Boolean ) of Integer;
   type T7 is access integer;
   type T8 (<>) is [limited] private;

------------------------------------
Generic Parameters Can Be Combined
------------------------------------

* Consistency is checked at compile-time

.. code:: Ada

   generic
      type T (<>) is limited private;
      type Acc is access all T;
      type Index is (<>);
      type Arr is array (Index range <>) of Acc;
   procedure P;

   type String_Ptr is access all String;
   type String_Array is array (Integer range <>)
       of String_Ptr;

   procedure P_String is new P
      (T     => String,
       Acc   => String_Ptr,
       Index => Integer,
       Arr   => String_Array);

------
Quiz
------

.. include:: quiz/generic_subp_syntax/quiz.rst

------
Quiz
------

.. code:: Ada

   generic
      type T1 is (<>);
      type T2 (<>) is private;
   procedure G
     (A : T1;
      B : T2);

Which is an illegal instantiation?

   A. :answermono:`procedure A is new G (String, Character);`
   B. ``procedure B is new G (Character, Integer);``
   C. ``procedure C is new G (Integer, Boolean);``
   D. ``procedure D is new G (Boolean, String);``

.. container:: animate

   :ada:`T1` must be discrete - so an integer or an enumeration. :ada:`T2` can be any type

=====================
Generic Formal Data
=====================

----------
Examples
----------

.. include:: examples/160_genericity/generic_formal_data.rst

:url:`https://learn.adacore.com/training_examples/fundamentals_of_ada/160_genericity.html#generic-formal-data`

--------------------------------------------
Generic Constants and Variables Parameters
--------------------------------------------

.. container:: columns

 .. container:: column

    * Variables can be specified on the generic contract
    * The mode specifies the way the variable can be used:

       - :ada:`in` |rightarrow| read only
       - :ada:`in out` |rightarrow| read write

    * Generic variables can be defined after generic types

 .. container:: column

    .. code:: Ada

       generic
          type T is private;
          X1 : Integer;  -- constant
          X2 : in out T; -- variable
       procedure P;

       V : Float;

       procedure P_I is new P
          (T  => Float,
           X1 => 42,
           X2 => V);

-------------------------------
Generic Subprogram Parameters
-------------------------------

* Subprograms can be defined in the generic contract
* Must be introduced by :ada:`with` to differ from the generic unit

   .. code:: Ada

      generic
         with procedure Callback;
      procedure P;
      procedure P is
      begin
         Callback;
      end P;
      procedure Something;
      procedure P_I is new P (Something);

----------------------------------------
Generic Subprogram Parameters Defaults
----------------------------------------

.. admonition:: Language Variant

   Ada 2005

* :ada:`is <>` - matching subprogram is taken by default
* :ada:`is null` - null subprogram is taken by default

   - Only available in Ada 2005 and later

   .. code:: Ada

      generic
        with procedure Callback1 is <>;
        with procedure Callback2 is null;
      procedure P;
      procedure Callback1;
      procedure P_I is new P;
      -- takes Callback1 and null

----------------------------
Generic Package Parameters
----------------------------

* A generic unit can depend on the instance of another generic unit
* Parameters of the instantiation can be constrained partially or completely

.. code:: Ada

   generic
      type T1 is private;
      type T2 is private;
   package Base is [...]

   generic
      with package B is new Base (Integer, <>);
      V : B.T2;
   package Other [...]

   package Base_I is new Base (Integer, Float);

   package Other_I is new Other (Base_I, 56.7);

------
Quiz
------

.. include:: quiz/genericity_type_and_variable/quiz.rst

------
Quiz
------

.. include:: quiz/genericity_limited_type/quiz.rst

------
Quiz
------

.. admonition:: Language Variant

   Ada 2005

.. container:: columns

 .. container:: column

  .. container:: latex_environment tiny

   .. code:: Ada
      :number-lines: 1

      procedure P1 (X : in out Integer); -- add 100 to X
      procedure P2 (X : in out Integer); -- add 20 to X
      procedure P3 (X : in out Integer); -- add 3 to X
      generic
         with procedure P1 (X : in out Integer) is <>;
         with procedure P2 (X : in out Integer) is null;
      procedure G ( P : integer );
      procedure G ( P : integer ) is
         X : integer := P;
      begin
         P1(X);
         P2(X);
         Ada.Text_IO.Put_Line ( X'Image );
      end G;
      procedure Instance is new G ( P1 => P3 );

 .. container:: column

  .. container:: latex_environment scriptsize

   What is printed when :ada:`Instance` is called?

   A. 100
   B. 120
   C. :answer:`3`
   D. 103

   .. container:: animate

      Explanations

      A. | Wrong - result for
         | :ada:`procedure Instance is new G;`
      B. | Wrong - result for
         | :ada:`procedure Instance is new G(P1,P2);`
      C. :ada:`P1` at line 12 is mapped to :ada:`P3` at line 3, and :ada:`P2` at line 14 wasn't specified so it defaults to :ada:`null`
      D. | Wrong - result for
         | :ada:`procedure Instance is new G(P2=>P3);`

====================
Generic Completion
====================

------------------------------
Implications at Compile-Time
------------------------------

* The body needs to be visible when compiling the user code
* Therefore, when distributing a component with generics to be instantiated, the code of the generic must come along

-----------------------------
Generic and Freezing Points
-----------------------------

* A generic type **freezes** the type and needs the **full view**
* May force separation between its declaration (in spec) and instantiations (in private or body)

.. code:: Ada

   generic
      type X is private;
   package Base is
      V : access X;
   end Base;

   package P is
      type X is private;
      -- illegal
      package B is new Base (X);
   private
      type X is null record;
   end P;

-------------------------------
Generic Incomplete Parameters
-------------------------------

* A generic type can be incomplete
* Allows generic instantiations before full type definition
* Restricts the possible usages (only :ada:`access`)

.. code:: Ada

   generic
      type X; -- incomplete
   package Base is
      V : access X;
   end Base;

   package P is
      type X is private;
      -- legal
      package B is new Base (X);
   private
      type X is null record;
   end P;

------
Quiz
------

.. include:: quiz/genericity_private_type/quiz.rst

========
Lab
========

.. include:: labs/160_genericity.lab.rst

=========
Summary
=========

-------------------------------------
Generic Routines vs Common Routines
-------------------------------------

.. code:: Ada

   package Helper is
      type Float_T is digits 6;
      generic
         type Type_T is digits <>;
         Min : Type_T;
         Max : Type_T;
      function In_Range_Generic (X : Type_T) return Boolean;
      function In_Range_Common (X   : Float_T;
                                Min : Float_T;
                                Max : Float_T)
                                return Boolean;
   end Helper;

   procedure User is
     type Speed_T is new Float_T range 0.0 .. 100.0;
     B : Boolean;
     function Valid_Speed is new In_Range_Generic
        (Speed_T, Speed_T'First, Speed_T'Last);
   begin
     B := Valid_Speed (12.3);
     B := In_Range_Common (12.3, Speed_T'First, Speed_T'Last);

.. container:: speakernote

   Generics increase code size and readability
   Common functions reduce size, but increase error possibilities

---------
Summary
---------

* Generics are useful for copying code that works the same just for different types

   - Sorting, containers, etc

* Properly written generics only need to be tested once

   - But testing / debugging can be more difficult

* Generic instantiations are best done at compile time

   - At the package level
   - Can be run-time expensive when done in subprogram scope
