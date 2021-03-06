# Hierarchical data templates
[![Gem Version](https://badge.fury.io/rb/cloud-templates.svg)](https://badge.fury.io/rb/cloud-templates)

> Template your world because everything is code.

The framework is an MVC-based templating engine for hierarchical data structures.
It promotes a logical extension to Infrastructure-as-Code paradigm.

## Why?
The template project was created as a reaction to the trends in Infrastructure-as-Code community
which we were not necessarily agree with. Namely, one of the trends which is still visible is
merging together infrastructure orchestration engine with extremely specialized DSL-based
templating system (Puppet, Chef). What becomes problematic is when you want to use both separately
mix-n-matching programming languages and technologies of your choice for either orchestration
engine or templating system. Also, it's not straightforward to use the same templating system for
generating different config files which are relevant to the infrastructure you are creating
(endpoint configs, loadbalancing parameters, etc).

In general, the purpose of the framework is to bring templating capabilities to the areas where
traditional approach for auto-generation (ERB can be an example) is problematic to apply.

Text-based templating frameworks work well when the resulting output has moderate number of
parameter-driven parts. For example, HTML output is perfect candidate for such templating.

Problem arises when you try to template:
* A data structure
* A hierarchy of nested datastructures
* All of the above with parent-child relations in types of the data
  structures

"Data structure" can be anything from XML, JSON, YAML, ASN or any domain-specific language.
The problem manifests itself in the fact that data representation is very condensed so user
ends up with a template where number of substitutions is bigger than static content.
Also, usually, text template engines don't provide mechanisms for template inheritance.

A practical examples of condensed data structure definition can be:
* CloudFormation template
* LDAP LDIF record
* SQL DML script

## Tenets (unless you know better ones)
The project has the following tenets:
* OOP everywhere: encapsulation, inheritance, polymorphism. The paradigm has proven to be viable
  over years of software development so let's re-use it for our solution.
* Native-language objects.
* Multi-language support. Programming language X will always be a new Perl in 5 years time.
* Developer experience and productivity is paramount.
* People is bad in writing code and documentation. Let's make the framework self-documenting and
  self-explanatory.
* Let's choose the scope abstract enough so we can adopt the framework to maximum number of use
  cases where linking two values is necessary.
* Let's choose a scope concrete enough to start optimizing against it.

## How?
The core idea of the framework is to use hierarchical hash merges
and transformations employing standard language class hierarchy and
object embedding. Class hierarchy models commonalities in data
structure types like LDAP classes.

Framework also accommodates for the fact that there might be graph
of relations between data structures in definition. Examples of
such dependencies could be people org structure where some people
can work on different project with their peers, can be participants
of different groups or virtual teams. Another example is
CloudFormation resource in CFN stack definition which can be depend
on other resources outputs or sole fact of existence.

The framework build with documentation and extended introspection
features in mind. To support that there is a part of DSL which is
designed for input hash checks and extracting parameters from it
needed at the current processing step. For instance, you can specify
parameter definition with constraints, default value, input hash
extraction path or calculation block. This way you can use this
parameter and be sure that all constraints are met, default value is
substituted and intermediate computations have been performed with
all errors happening in this process wrapped in exceptions
containing explaining what should be fixed.

The framework consists of a few decoupled parts which can be used
independently. Namely:
* Options class. It implements the core part of hash merging mechanics.
  Also it implements hierarchical structure look-up mechanism so
  you can specify wildcard configurations in your input parameters
  or output hash if it is to be consumed by someone else
* Parametrized mixin. It implements hash parameters checking and
  embodies consepts of getters (to extract parameter value for examination),
  transformations (to pre-process the parameter value), constraints
  (to examine parameter value). It defines DSL for parameter definition.
  When applied it auto-generates options accessors with value lookup in input
  hash, constraints validation, value transformations and extended exceptions
  handling if an error encountered during those stages
* Defaults mixin. It implements class scope DSL definitions of default values.
  The defaults can contain nested definitions (through nested hashes) and
  lambdas which will be evaluated in instance scope when an object of a class
  with the mixin is created. All defaults defined in the inheritance hierarchy
  and mixin hierarchy are merged with rules of precedence.
* Optionable class. A convenience intersection of embedded accessor
  for Options field and Parametrized mixin. The basis for artifacts.
* Constraint class and children. They are concrete constraint types
  for Parametrized mixin.
* Getter class and children. They are concrete look-up methods for
  Parametrized mixin.
* Transformation class and children. They are concrete type
  transformation methods for Parametrized mixin.
* Named mixin. A convenience util mixin which can be used for either
  parameters as_object definitions which should contain "name" field
  or as an artifact parameters definition mixin
* Artifact class. Represents basic datastructure type class and
  the main vehicle of the framework.
* Composite class. A kind of BasicArtifact which is able to
  embed other artifacts. This is a recursive structure so composite
  can contain other composites since a composite is an artifact.
* Processor which embodies a basis for renders and documentation
  providers (see below)
* Render mixin and View classes. To "render" means to transform an
  artifact into a domain-specific representation like SQL DML statement,
  LDIF definition, etc. Each artifact to be rendered should have an attached
  view in the scope of the concrete render used. The link between two is
  defined in a concrete child of View class. Views can be inherited so if you
  have a universal way to render all your artifacts you can just link a single
  render to Artifact class. Artifact can have *multiple* renders. For instance,
  you can generate both SQL DML and JSON from the same artifact definition. Or
  you can automate human-readable description creation like wiki
  pages if you want to describe in words what CloudFromation stack
  definition would create.
* Documentation providers which automatically generate documentation for
  artifacts and framework constructs extracting meta-information provided
  by parameter definitions
* Dependency tracking mechanism which allows to track dependencies between
  objects without explicit specification of it. Also, explicit dependency
  tracking handles are provided through usage of special methods.

## Roadmap

* Optimization of internal logic
* Error message and exception handling improvements:
  * Each exception should have clear indication of where the problem originates
* Embedded, class-based help
  * Blurb should contain general description
  * Help messages and documentation should support embedded pieces of sample code from examples
    instead of inlining Ruby code directly into the doc
  * Examples should be runnable directly inside of IRB
  * Supported options list and provided defaults should be auto-generated from parameter
    descriptions
* Internationalization
  * Help messages should support pluggable content
  * Exceptions should support regionalized messages
* Model-agnostic HTML/JS/SVG render
* Integrated IDE for constructing object schemas (Ruby interactive interpreter combined with
  GUI)
* Assessment of the need of deep processing speed optimization:
  * Assessment of alternative language technologies (Rust, Scala, C++, D) for re-implementation
  * Assessment of moving separate parts to native code
