# testing-dsl-playground

A place to experiment with what my testing DSL will look like

## Purpose

Create a language to describe the bits and pieces of a software system,
as well as the process for creating that system, from requirements to 
test cases and everything in between.

Also, build a collection of tools to interpret that language, and 
facilitate exploration and generation of artifacts and/or processes.

The language will be concise and interpretable by both human and machine. 
It is purely declarative - imperative logic is actively avoided.
It is meant to capture the essence of the domain-specific details with
precision and clarity, while being as self-explanatory as possible.

The goals of this project are:

* Facilitate communication between team members
  * Business Users <-> The Development Team
  * Domain Experts <-> Quality Assurance
  * Developers <-> Quality Assurance

* Provide living, value-adding, executable documentation
  * Provide a model of the system
    * The model is human readable - serves as documentation
    * The model is computer readable
      * Can execute constrained syntax BDD-style tests directly against the design
      * Can enumerate all possible paths through the system (or a part of it)
        * For requirements gap detection
        * For design gap detection
        * For design defect detection 
        * For test matrix generation
      * Can be transformed into other artifacts as needed

* Track how everything relates
  * These requirements are validated by these test cases
  * These test cases apply under these conditions
  * This feature is built on these components
  * These components are fed from these other components

## Features

* Describe everything in a clear and concise DSL
  * Allows concepts to be communicated quickly, clearly, concisely, 
    regardless of their level of experience with the tool
  * Allows the specifications to be checked into version control
  * Allows collaboration on the construction of the specifications
  * Allows code to be written to process the DSL and automatically 
    generate artifacts or more DSL

* Language is declarative: 
  * This is what it is
  * This is what it does
  * But not so much how it does it

* IDEALY: Extensible - The core language provides syntax rules, and the 
  rest is constructed in that language

* An IDE, or plugins for popular IDEs, that aid the DSL construction, and 
  in some cases provide GUI interfaces for constructing the objects that 
  the DSL are describing

* Possibly some day include a hosted version of the IDE, as a means to monitizing the tool and supporting its ongoing development

* FUTURE: Generate specifications from source code - build tools that can take source code and recognize elements from the language and build a draft specification that can be used as a starting point for building test suites, documentation, etc.

## What is Tracked

The plan is to make it extensible, so you can track basically anything,
and relate everything however you see fit.  So for example, you COULD build a suite that includes:

* Actors / Roles
* Use Cases
* Requirements
* Features
* Stories
* Acceptance Criteria
* Test Cases
* Test Conditions
* Test Operations
* Test Matrices
* Defects
* Data Models
* Class Models
* Process Models
* Interface Models

And if you took the time to build all of this, you could construct translators that generate your documentation, your test matrices, your database DDL, your persistence layer, your service layer, and so on.  The only part that would actually need to be coded would be your custom business logic.

Of course, in reality, most projects will only implement some of these, based on which ones offer the most value and fit well into the way they understand the problem at hand.  A core design philosophy is that the tool does not require you to use it for everything including the kitchen sink in order to get value from it.  Take what you need, ignore the rest.

Another core value of the tool is that it becomes a repository of knowledge.  For example, an organization can define certain common requirements that every product is expected to adhere to.  Requirements like authentication, authorization, schema enforcement, data integrity, multi-user capability, accessability, internationalization, etc.  For each of those core common requirements, test cases can be defined, and those requirements can be set up to be inherited whenever an object of a certain type is defined with a certain attribute.  Then, for example, the simple act of defining an API and properly annotating it allows the tool to generate a comprehensive list of requirements and the test cases that will verify that those requirements are being met.  

Indeed, the goal of the tool is not just to facilitate that capture and 
communication of domain knowledge.  It is also to build a centralized 
repository of that knowledge so that everyone in the industry can benefit 
from the collective wisdom of those who contribute to that repository.

## The Core Language

The language is centered around building definitions of things, so that
those definitions can be explored and reasoned about.  The language is
primarily concerned with defining those things.  Therefore, the language
is exclusively focused on constructing Objects in a clear and concise 
way, that lets you re-use things whenever it makes sense to do so.

**Types** - Defines a local DSL for describing the words and syntax
  that can be used to construct a particular type of object

* The properties that can be set
* Limits on what kinds of values can be set in those properties
* Limits on what specific values can be set
* Flags for setting specific properties to specific values

**Objects** - A specific named instance of a particular type

* Objects have a type, which is used to aid the parsing
* Objects can inherit from other objects of the same type
* That means being initialized by cloning those other objects
