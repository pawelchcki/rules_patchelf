"""patchelf_print rule"""

_patchelf_print_doc = """\
dump all information patchelf can provide

```py
patchelf_print(
    name = "print_output",
    args = ["--print-rpath"],
    src = ":lib",
)
```
"""

def _patchelf_print_impl(ctx):
    """'patchelf_rule' rule implementation

    Args:
        ctx: A context object that is passed to the implementation function for a rule or aspect.
    Returns:
        (list) a list of Providers
    """

    src = ctx.attr.src

    # Determine the location of the patchelf executable
    toolchain = ctx.toolchains["//patchelf:patchelf_toolchain"]
    patchelf_bin = toolchain.patchelf

    all_dyn_library_files = [
        library.dynamic_library
        for input in src[CcInfo].linking_context.linker_inputs.to_list()
        for library in input.libraries
        if library.dynamic_library
    ]

    files = src[DefaultInfo].files.to_list()

    elf_file = None
    if len(files) == 1:
        elf_file = files[0]
    elif len(all_dyn_library_files):
        elf_file = all_dyn_library_files[0]

    if not elf_file:
        fail("src dependendency must contain exactly one elf file")

    inputs = depset(direct = [elf_file])

    dump_output = ctx.actions.declare_file(ctx.label.name)

    args = ctx.actions.args()
    args.add_all(ctx.attr.args)
    args.add(elf_file.path)

    ctx.actions.run_shell(
        mnemonic = "PatchelfPrint",
        progress_message = "Reading elf {} ..".format(elf_file.short_path),
        outputs = [dump_output],
        arguments = [args],
        command = '"%s" "$@" > "%s"' % (patchelf_bin.path, dump_output.path),
        tools = depset(direct = [patchelf_bin]),
        inputs = inputs,
    )

    return [
        DefaultInfo(
            files = depset([dump_output]),
        ),
    ]

patchelf_print = rule(
    implementation = _patchelf_print_impl,
    doc = _patchelf_print_doc,
    attrs = {
        "src": attr.label(
            doc = "TODO",
            providers = [CcInfo],
            mandatory = True,
        ),
        "args": attr.string_list(
            mandatory = False,
            allow_empty = True,
            default = ["--print-soname"],
            doc = "TODO",
        ),
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
        ),
    },
    outputs = {
    },
    toolchains = [
        "//patchelf:patchelf_toolchain",
    ],
)
