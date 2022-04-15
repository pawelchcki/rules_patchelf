# rules_patchelf

Simple set of bazel rules wrapping nixos's patchelf utility

<a id="patchelf_library"></a>

## patchelf_library

<pre>
patchelf_library(<a href="#patchelf_library-name">name</a>, <a href="#patchelf_library-args">args</a>, <a href="#patchelf_library-lib">lib</a>)
</pre>

modify shared elf library

```py
patchelf_library(
    name = "lib_patchelf",
    args = [""]
    lib = ":lib",
)

cc_binary(
    name = "bin",
    srcs = ["main.cc"],
    deps = [":lib_patchelf"],
)
```


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="patchelf_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="patchelf_library-args"></a>args |  TODO   | List of strings | optional | [] |
| <a id="patchelf_library-lib"></a>lib |  TODO   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |


<a id="patchelf_print"></a>

## patchelf_print

<pre>
patchelf_print(<a href="#patchelf_print-name">name</a>, <a href="#patchelf_print-args">args</a>, <a href="#patchelf_print-src">src</a>)
</pre>

dump all information patchelf can provide

```py
patchelf_print(
    name = "print_output",
    args = ["--print-rpath"],
    src = ":lib",
)
```


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="patchelf_print-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="patchelf_print-args"></a>args |  TODO   | List of strings | optional | ["--print-soname"] |
| <a id="patchelf_print-src"></a>src |  TODO   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |


