***********************
Low Level Programming
***********************

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

--------------
Introduction
--------------

* Sometimes you need to get your hands dirty
* Hardware Issues

   - Register or memory access
   - Assembler code for speed or size issues

* Interfacing with other software

   - Object sizes
   - Endianness
   - Data conversion

=====================
Data Representation
=====================

-------------------------------------
Data Representation vs Requirements
-------------------------------------

* Developer usually defines requirements on a type

   .. code:: Ada

      type My_Int is range 1 .. 10;

* The compiler then generates a representation for this type that can accommodate requirements

   - In GNAT, can be consulted using ``-gnatR2`` switch

      .. code:: Ada

         type My_Int is range 1 .. 10;
         for My_Int'Object_Size use 8;
         for My_Int'Value_Size  use 4;
         for My_Int'Alignment   use 1;

         -- using Ada 2012 aspects
         type Ada2012_Int is range 1 .. 10
            with Object_Size => 8,
                 Value_Size  => 4,
                 Alignment   => 1;

* These values can be explicitly set, the compiler will check their consistency
* They can be queried as attributes if needed

   .. code:: Ada

      X : Integer := My_Int'Alignment;

---------------------
`Value_Size / Size`
---------------------

* `Value_Size` (or `Size` in the Ada Reference Manual) is the minimal number of bits required to represent data

   - For example, :ada:`Boolean'Size = 1`

* The compiler is allowed to use larger size to represent an actual object, but will check that the minimal size is enough

   .. code:: Ada

      type T1 is range 1 .. 4;
      for T1'Size use 3;

      -- using Ada 2012 aspects
      type T2 is range 1 .. 4
         with Size => 3;

-----------------------------
Object Size (GNAT-Specific)
-----------------------------

* `Object_Size` represents the size of the object in memory
* It must be a multiple of `Alignment * Storage_Unit (8)`, and at least equal to `Size`

   .. code:: Ada

      type T1 is range 1 .. 4;
      for T1'Value_Size use 3;
      for T1'Object_Size use 8;

      -- using Ada 2012 aspects
      type T2 is range 1 .. 4
         with Value_Size  => 3,
              Object_Size => 8;

* Object size is the *default* size of an object, can be changed if specific representations are given

-----------
Alignment
-----------

* Number of bytes on which the type has to be aligned
* Some alignment may be more efficient than others in terms of speed (e.g. boundaries of words (4, 8))
* Some alignment may be more efficient than others in terms of memory usage

   .. code:: Ada

      type T1 is range 1 .. 4;
      for T1'Size use 4;
      for T1'Alignment use 8;

      -- using Ada 2012 aspects
      type T2 is range 1 .. 4
         with Size      => 4,
              Alignment => 8;

--------------
Record Types
--------------

.. container:: columns

 .. container:: column

    * Ada doesn't force any particular memory layout
    * Depending on optimization of constraints, layout can be optimized for speed, size, or not optimized

    .. code:: Ada

       type Enum is (E1, E2, E3);
       type Rec is record
          A : Integer;
          B : Boolean;
          C : Boolean;
          D : Enum;
       end record;

 .. container:: column

    .. image:: record_packing_examples.png
       :width: 50%

-------------
Pack Aspect
-------------

* `pack` aspect (or pragma) applies to composite types (record and array)
* Compiler optimizes data for size no matter performance impact
* Unpacked

   .. code:: Ada

      type Enum is (E1, E2, E3);
      type Rec is record
         A : Integer;
         B : Boolean;
         C : Boolean;
         D : Enum;
      end record;
      type Ar is array (1 .. 1000) of Boolean;
      -- Rec'Size is 56, Ar'Size is 8000

* Packed

   .. code:: Ada

      type Enum is (E1, E2, E3);
      type Rec is record
         A : Integer;
         B : Boolean;
         C : Boolean;
         D : Enum;
      end record with Pack;
      type Ar is array (1 .. 1000) of Boolean;
      pragma Pack (Ar);
      -- Rec'Size is 36, Ar'Size is 1000

-------------------------------
Record Representation Clauses
-------------------------------

.. container:: columns

 .. container:: column

    * Exact mapping between a record and its binary representation
    * Optimization purposes, or hardware requirements

       - Driver mapped on the address space, communication protocol...

    * Fields represented as

      .. code:: Ada

        <name> at <byte> range
           <starting-bit> ..
           <ending-bit>

 .. container:: column

      .. code:: Ada

        type Rec1 is record
           A : Integer range 0 .. 4;
           B : Boolean;
           C : Integer;
           D : Enum;
        end record;
        for Rec1 use record
           A at 0 range 0 ..  2;
           B at 0 range 3 ..  3;
           C at 0 range 4 .. 35;
           -- unused space here
           D at 5 range 0 ..  2;
        end record;

------------------------------
Array Representation Clauses
------------------------------

* :ada:`Component_Size` for array's **component's** size

.. code:: Ada

   type Ar1 is array (1 .. 1000) of Boolean;
   for Ar1'Component_Size use 2;

   -- using Ada 2012 aspects
   type Ar2 is array (1 .. 1000) of Boolean
       with Component_Size => 2;

--------------------------
Endianness Specification
--------------------------

* `Bit_Order` for a type's endianness
* `Scalar_Storage_Order` for composite types

    - Endianess of components' ordering
    - GNAT-specific
    - Must be consistent with `Bit_Order`

* Compiler will peform needed bitwise transformations when performing operations

.. code:: Ada

   type Rec is record
      A : Integer;
      B : Boolean;
   end record;
   for Rec use record
      A at 0 range 0 .. 31;
      B at 0 range 32 .. 33;
   end record;
   for Rec'Bit_Order use System.High_Order_First;
   for Rec'Scalar_Storage_Order use System.High_Order_First;

   -- using Ada 2012 aspects
   type Ar is array (1 .. 1000) of Boolean with
     Scalar_Storage_Order => System.Low_Order_First;

--------------------------
Change of Representation
--------------------------

* Explicit new type can be used to set representation
* Very useful to unpack data from file/hardware to speed up references

.. code:: Ada

    type Rec_T is record
         Field1 : Unsigned_8;
         Field2 : Unsigned_16;
         Field3 : Unsigned_8;
    end record;
    type Packed_Rec_T is new Rec_T;
    for Packed_Rec_T use record
       Field1 at 0 range  0 ..  7;
       Field2 at 0 range  8 .. 23;
       Field3 at 0 range 24 .. 31;
    end record;
    R : Rec_T;
    P : Packed_Rec_T;
    ...
    R := Rec_T (P);
    P := Packed_Rec_T (R);

.. container:: speakernote

   Size of R is probably 48 (for 16-bit alignment) or 96 (for 32-bit alignment)
   Size of P will always be 32

==============================
Address Clauses and Overlays
==============================

---------
Address
---------

* Ada distinguishes the notions of

   - A reference to an object
   - An abstract notion of address (`System.Address`)
   - The integer representation of an address

* Safety is preserved by letting the developer manipulate the right level of abstraction
* Conversion between pointers, integers and addresses are possible
* The address of an object can be specified through the `Address` aspect

-----------------
Address Clauses
-----------------

* Ada allows specifying the address of an entity

   .. code:: Ada

      Var : Unsigned_32;
      for Var'Address use ... ;

* Very useful to declare I/O registers

   - For that purpose, the object should be declared volatile:

   .. code:: Ada

      pragma Volatile (Var);

* Useful to read a value anywhere

   .. code:: Ada

      function Get_Byte (Addr : Address) return Unsigned_8 is
        V : Unsigned_8;
        for V'Address use Addr;
        pragma Import (Ada, V);
      begin
        return V;
      end;

   - In particular the address doesn't need to be constant
   - But must match alignment

----------------
Address Values
----------------

* The type `Address` is declared in `System`

   - But this is a :ada:`private` type
   - You cannot use a number

* Ada standard way to set constant addresses:

   - Use `System.Storage_Elements` which allows arithmetic on address

   .. code:: Ada

      for V'Address use
          System.Storage_Elements.To_Address (16#120#);

* GNAT specific attribute `'To_Address`

   - Handy but not portable

   .. code:: Ada

      for V'Address use System'To_Address (16#120#);

----------
Volatile
----------

* The `Volatile` property can be set using an aspect (in Ada2012 only) or a pragma
* Ada also allows volatile types as well as objects.

   .. code:: Ada

      type Volatile_U16 is mod 2**16;
      pragma Volatile(Volatile_U16);
      type Volatile_U32 is mod 2**32 with Volatile; -- Ada 2012

* The exact sequence of reads and writes from the source code must appear in the generated code.

   - No optimization of reads and writes

* Volatile types are passed by-reference.

---------------------
Ada Address Example
---------------------

.. code:: Ada

   type Bitfield is array (Integer range <>) of Boolean;
   pragma Component_Size (1);

   V  : aliased Integer; -- object can be referenced elsewhere
   pragma Volatile (V);  -- may be updated at any time

   V2 : aliased Integer;
   pragma Volatile (V2);

   V_A : System.Address := V'Address;
   V_I : Integer_Address := To_Integer (V_A);

   --  This maps directly on to the bits of V
   V3 : aliased Bitfield (1 .. V'Size);
   for V3'Address use V_A; -- overlay

   V4 : aliased Integer;
   --  Trust me, I know what I'm doing, this is V2
   for V4'Address use To_Address (V_I - 4);

--------------------
Aliasing Detection
--------------------

* :dfn:`Aliasing`: multiple objects are accessing the same address

   - Types can be different
   - Two pointers pointing to the same address
   - Two references onto the same address
   - Two objects at the same address

* :ada:`Var1'Has_Same_Storage (Var2)` checks if two objects occupy exactly the same space
* :ada:`Var'Overlaps_Storage (Var2)` checks if two object are partially or fully overlapping

----------------------
Unchecked Conversion
----------------------

* `Unchecked_Conversion` allows an unchecked *bitwise* conversion of data between two types.
* Needs to be explicitly instantiated

   .. code:: Ada

      type Bitfield is array (1 .. Integer'Size) of Boolean;
      function To_Bitfield is new
         Ada.Unchecked_Conversion (Integer, Bitfield);
      V : Integer;
      V2 : Bitfield := To_Bitfield (V);

* Avoid conversion if the sizes don't match

   - Not defined by the standard

=================
Inline Assembly
=================

-----------------------
Calling Assembly Code
-----------------------

* Calling assembly code is a vendor-specific extension
* GNAT allows passing assembly with `System.Machine_Code.ASM`

   - Handled by the linker directly

* The developer is responsible for mapping variables on temporaries or registers
* See documentation

   - GNAT RM 13.1 Machine Code Insertion
   - GCC UG 6.39 Assembler Instructions with C Expression Operands

------------------
Simple Statement
------------------

* Instruction without inputs/outputs

   .. code:: Ada

      Asm ("halt", Volatile => True);

   - You may specify `Volatile` to avoid compiler optimizations
   - In general, keep it False unless it created issues

* You can group several instructions

   .. code:: Ada

      Asm ("nop" & ASCII.LF & ASCII.HT
           & "nop", Volatile => True);
      Asm ("nop; nop", Volatile => True);

* The compiler doesn't check the assembly, only the assembler will

   - Error message might be difficult to read

----------
Operands
----------

* It is often useful to have inputs or outputs...

   - `Asm_Input` and `Asm_Output` attributes on types

.. image:: annotated_assembly_statement.png
   :width: 85%

-----------------------------------------
Mapping Inputs / Outputs on Temporaries
-----------------------------------------

.. code:: Ada

  Asm (<script referencing $<input> >,
       Inputs  => ({<type>'Asm_Input ( <constraint>,
                                       <variable>)}),
       Outputs => ({<type>'Asm_Output ( <constraint>,
                                        <variable>)});

* **assembly script** containing assembly instructions + references to registers and temporaries
* **constraint** specifies how variable can be mapped on memory (see documentation for full details)

 .. list-table::
   :header-rows: 1
   :stub-columns: 1

   * - Constraint

     - Meaning

   * - R

     - General purpose register

   * - M

     - Memory

   * - F

     - Floating-point register

   * - I

     - A constant

   * - g

     - global (on x86)

   * - a

     - eax (on x86)

------------
Main Rules
------------

* No control flow between assembler statements

   - Use Ada control flow statement
   - Or use control flow within one statement

* Avoid using fixed registers

   - Makes compiler's life more difficult
   - Let the compiler choose registers
   - You should correctly describe register constraints

* On x86, the assembler uses ``AT&T`` convention

   - First operand is source, second is destination

* See your toolchain's ``as`` assembler manual for syntax

-------------------------------------
Volatile and Clobber ASM Parameters
-------------------------------------

* :ada:`Volatile` |rightarrow| :ada:`True` deactivates optimizations with regards to suppressed instructions
* :ada:`Clobber` |rightarrow| :ada:`"reg1, reg2, ..."` contains the list of registers considered to be "destroyed" by the use of the ASM call

   - ``memory`` if the memory is accessed

      + Compiler won't use memory cache in registers across the instruction.

   - ``cc`` if flags might have changed

-----------------------------------
Instruction Counter Example (x86)
-----------------------------------

.. code:: Ada

   with System.Machine_Code; use System.Machine_Code;
   with Ada.Text_IO;         use Ada.Text_IO;
   with Interfaces;          use Interfaces;
   procedure Main is
      Low   : Unsigned_32;
      High  : Unsigned_32;
      Value : Unsigned_64;
      use ASCII;
   begin
      Asm ("rdtsc" & LF,
           Outputs =>
              (Unsigned_32'Asm_Output ("=g", Low),
               Unsigned_32'Asm_Output ("=a", High)),
           Volatile => True);
      Values := Unsigned_64 (Low) +
                Unsigned_64 (High) * 2 ** 32;
      Put_Line (Values'Image);
   end Main;

----------------------------------
Reading a Machine Register (ppc)
----------------------------------

.. code:: Ada

   function Get_MSR return MSR_Type is
      Res : MSR_Type;
   begin
      Asm ("mfmsr %0",
           Outputs => MSR_Type'Asm_Output ("=r", Res),
           Volatile => True);
      return Res;
   end Get_MSR;
   generic
       Spr : Natural;
    function Get_Spr return Unsigned_32;
    function Get_Spr return Unsigned_32 is
       Res : Unsigned_32;
    begin
       Asm ("mfspr %0,%1",
            Inputs => Natural'Asm_Input ("K", Spr),
            Outputs => Unsigned_32'Asm_Output ("=r", Res),
            Volatile => True);
       return Res;
    end Get_Spr;
    function Get_Pir is new Get_Spr (286);

----------------------------------
Writing a Machine Register (ppc)
----------------------------------

.. code:: Ada

   generic
      Spr : Natural;
   procedure Set_Spr (V : Unsigned_32);
   procedure Set_Spr (V : Unsigned_32) is
   begin
      Asm ("mtspr %0,%1",
           Inputs => (Natural'Asm_Input ("K", Spr),
                      Unsigned_32'Asm_Input ("r", V)));
   end Set_Spr;

========
Tricks
========

--------------------
Package Interfaces
--------------------

* Package `Interfaces` provide integer and unsigned types for many sizes

   - `Integer_8`, `Integer_16`, `Integer_32`, `Integer_64`
   - `Unsigned_8`, `Unsigned_16`, `Unsigned_32`, `Unsigned_64`

* With shift/rotation functions for unsigned types

------------------------------
Fat/Thin pointers for Arrays
------------------------------

* Unconstrained array access is a fat pointer

   .. code:: Ada

      type String_Acc is access String;
      Msg : String_Acc;
      -- array bounds stored outside array pointer

* Use a size representation clause for a thin pointer

   .. code:: Ada

      type String_Acc is access String;
      for String_Acc'size use 32;
      -- array bounds stored as part of array pointer

-------------
Flat Arrays
-------------

* A constrained array access is a thin pointer

   - No need to store bounds

   .. code:: Ada

      type Line_Acc is access String (1 .. 80);

* You can use big flat array to index memory

   - See `GNAT.Table`
   - Not portable

   .. code:: Ada

      type Char_array is array (natural) of Character;
      type C_String_Acc is access Char_Array;

========
Lab
========

.. include:: labs/adv_280_low_level_programming.lab.rst

=========
Summary
=========

---------
Summary
---------

* Like C, Ada allows access to assembly-level programming
* Unlike C, Ada imposes some more restrictions to maintain some level of safety
* Ada also supplies language constructs and libraries to make low level programming easier
