
*******************
Adoption Guidance
*******************

-------------------------
SPARK Adoption Guidance
-------------------------

* So, now what? How do you go about adopting SPARK into real-world applications?
* Thales has been doing just that since 2009
* They wrote a document based on their experience, in combination with AdaCore

----------------------------
Adoption Guidance Document
----------------------------

.. container:: columns

 .. container:: column

    * Based on adoption experience
    * Proposes adoption levels
    * For every level, presents:

       - Benefits, impact on process, costs, and limitations
       - Setup and tool usage
       - Messages issued by the tool
       - Remediation solutions

 .. container:: column

    .. image:: thales_adoption_manual.png
       :width: 100%

-----------------------------------------
Responding To New Industrial Challenges
-----------------------------------------

.. image:: when_to_switch_to_spark.png

.. container:: speakernote

   What is this diagram trying to show?
   There are different clients with different requirements.
   Some will want only to develop new code from scratch, some want to analyze existing code, some want to do a mixture.

-----------------------------------------
Responding To New Industrial Challenges
-----------------------------------------

* Usage scenarios - develop new code from scratch

   - Contracts developed in advance of code (or at least in parallel)

      + SPARK can be used as architectural design language

   - Information flow contracts specified and checked to:

      + Find uninitialized variables
      + Find unused assignments
      + To check flows are as expected
      + To check safety or security properties

   - Proof / test

      + To show no exceptions will be raised at run time
      + To demonstrate correctness (including termination)

-----------------------------------------
Responding To New Industrial Challenges
-----------------------------------------

* Usage scenarios - analyze existing Ada code

   - Determine how much is "in SPARK"
   - For code that is "in SPARK"

      + Find (or show freedom from) flow errors
      + Find (or show freedom from) run-time exceptions

   - No contracts need to be added

      + This could be a preliminary step prior to adding contracts for further analysis
      + Some contracts can be generated by the tools

.. container:: speakernote

   Only global and depends contracts are synthesized at present:
   x if there is a contract, is it used to do all analysis (body is checked against the contract)
   x if there is no contract but a SPARK body, is a global contract synthesized (once) from the body and used (subsequently) for analysis of all calls to the spec.
   x  A default depends contract is assumed from the global contract (which may be synthesized) if a depends aspect is not provided.
   x If there is no contract and the body is not SPARK a global contract is still synthesized.  It may be a too conservative approximation and the use of pointers will introduce a heap global.
   x If there is no contract and the body does not exist a global contract of null (it uses no globals) is assumed.
   x Pre and postconditions are not synthesized.  The default pre and post conditions of True are used if they are not present.

-----------------------------------------
Responding To New Industrial Challenges
-----------------------------------------

* Usage scenarios - extend existing Ada code with SPARK 2014

   - Analyze as much of existing code as possible (as per previous slide)
   - Or, if code is in SPARK 2005, consider converting it to SPARK 2014
   - New code written in SPARK 2014 and subject to

      + Flow analysis (with or without dependency contracts)

      + RTE proof

      + Correctness proof (maybe)

----------------
Using Profiles
----------------

* Users may wish to impose restrictions, based on their particular usage scenario
* SPARK 2014 uses the concept of "Profiles" (as defined in Ada RM) to select desired sets of restrictions
* Some examples:

   .. code:: Ada

      pragma Restrictions (No_Recursion);
      pragma Restrictions (No_Implicit_Heap_Allocations);
      pragma Restrictions (No_Exceptions);

-----------------------------------
Scope and Level of SPARK Analysis
-----------------------------------

* Scope may be the entire project, only some units, or only parts of units
* Levels range from simple guarantees provided by flow analysis, to proofs of complex abstract properties
* Suggested levels for adopting SPARK

   :Stone level: Valid SPARK
   :Bronze level: Initialization and correct data flow
   :Silver level: Absence of run-time errors (AoRTE)
   :Gold level: Proof of key integrity properties
   :Platinum level: Full functional proof of requirements

-------------
Stone Level
-------------

* Goal: to identify as much code as possible that belongs to the SPARK subset

   - Program respects all SPARK language legality rules

* Defines a strong semantic coding standard
* Enforces safer use of language features

   - Restricted concurrency (Ravenscar profile)
   - Expressions and functions without side-effects

* Forbids language features precluding analysis

   - E.g., exception handlers

* More understandable, maintainable code as a result

--------------------------
Stone Level Code Changes
--------------------------

* May be extensive, but relatively shallow

   - E.g., change functions with side-effects into procedures

* Hide unsupported use of pointers (e.g. doubly linked list)

   - Within package bodies
   - Dereferences changed to function calls
   - Probably the most extensive effort
   - Where unsupported pointers remain, turn off `SPARK_Mode`

* Etc.
* See the Adoption Guide for how to make changes

   - Extensive examples provided!

--------------
Bronze Level
--------------

* Goal: verify initialization and correct data flow

   - No violations during SPARK flow analysis

* Detects programming errors

   - Reading uninitialized data
   - Problematic aliasing between parameters
   - Data race between concurrent tasks

* Checks user specifications

   - Data read or written
   - Flow of information from inputs to outputs

--------------
Silver Level
--------------

* Goal: prove absence of run-time errors

   - Thus no exceptions due to language-defined checks

* Detects programming errors

   - Divide by zero
   - Array index out of bounds
   - Integer, fixed-point and floating-point overflow
   - Explicit exception raised
   - Others...

* Hence no buffer overflows, etc. !
* Can replace defensive code raising exceptions with proven preconditions

---------------------
Silver Level Issues
---------------------

* An initial pass is required to either rewrite code or justify false alarms

   - Once complete, ongoing maintenance can maintain the same guarantees at reasonable cost

* Special treatment is required for loops, which may need loop invariants

   - Not trivial, see the SPARK User's Guide

* The initial pass may require a substantial effort to get rid of all false alarms

------------
Gold Level
------------

* Goal: proof of key integrity properties

   - Typically derived from software requirements

   - Maintaining critical data invariants throughout execution

* Works with Silver level to ensure program integrity

   - Control flow cannot be circumvented through run-time errors

   - Data cannot be corrupted

* Program passes SPARK proof without violations

---------------------
Gold Level Benefits
---------------------

* Build on top of Bronze and Silver level benefits
* No reads of uninitialized variables
* No possible interference between parameters and global variables
* No unintended access to global variables
* No run-time errors
* Cheaper to prove than to test to same confidence
* Proven properties don't require testing

   - Lower development costs

----------------------------------
Gold Level Costs and Limitations
----------------------------------

* The analysis may take a long time

   - Up to a few hours on large programs
   - But is guaranteed to terminate

* May require adding more precise types (ranges)
* May require adding more preconditions and postconditions
* Even if a property is provable, automatic provers may fail to prove it due to limitations of the provers

   - Non-linear integer arithmetic (e.g., division and modulo) operations
   - Floating-point arithmetic

----------------
Platinum Level
----------------

* Goal: full functional proof of requirements
* Program passes SPARK proof without violations
* Verifies complete user specifications:

   - Type invariants (weak and strong)
   - Preconditions
   - Postconditions

* Verifies loop termination (loop variant)
* Platinum level is not recommended during initial adoption of SPARK

   - Not easy...
