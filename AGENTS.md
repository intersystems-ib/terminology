# AGENTS

ObjectScript notes for this repo:

- Build list values with `$LB("one","two")`.
- Use `Return` to return a value from methods. Do not use prompt-returning forms like `Quit:condition value`.
- Use `$Get` for globals and multidimensional property access. Do not wrap ordinary object properties like `obj.Prop` in `$Get(...)`.
