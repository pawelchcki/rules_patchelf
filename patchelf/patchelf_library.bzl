"""patchelf rule"""

load("@rules_cc//cc:find_cc_toolchain.bzl", "find_cpp_toolchain")

_patchelf_doc = """\
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
"""

def _patchelf_library_impl(ctx):
    """'patchelf_rule' rule implementation

    Args:
        ctx: A context object that is passed to the implementation function for a rule or aspect.
    Returns:
        (list) a list of Providers
    """

    # Ensure the target lib is compatible with this rule.
    cc_lib = ctx.attr.lib

    # Determine the location of the patchelf executable
    toolchain = ctx.toolchains["//patchelf:patchelf_toolchain"]
    patchelf_bin = toolchain.patchelf

    all_dyn_library_files = [
        (input, library)
        for input in cc_lib[CcInfo].linking_context.linker_inputs.to_list()
        for library in input.libraries
        if library.dynamic_library
    ]

    if len(all_dyn_library_files) != 1:
        fail("more than one dynamic library file found in 'lib' dependency")

    file_to_link = all_dyn_library_files[0][1]
    old_linker_input = all_dyn_library_files[0][0]

    elf_file = file_to_link.dynamic_library

    inputs = depset(
        [elf_file],
    )

    lib_output = ctx.actions.declare_file("{}.{}".format(ctx.label.name, elf_file.extension))

    args = ctx.actions.args()
    args.add_all(ctx.attr.args)
    args.add("--output")
    args.add(lib_output)
    args.add("--print-rpath")
    args.add(elf_file.path)

    cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features + ["linker_flags"],
    )

    new_linker_input = cc_common.create_linker_input(
        owner = ctx.label,
        libraries = depset(direct = [
            cc_common.create_library_to_link(
                actions = ctx.actions,
                feature_configuration = feature_configuration,
                cc_toolchain = cc_toolchain,
                dynamic_library = lib_output,
            ),
        ]),
        user_link_flags = old_linker_input.user_link_flags,
    )

    ctx.actions.run(
        mnemonic = "Patchelf",
        progress_message = "Patching elf {} ..".format(ctx.attr.lib),
        outputs = [lib_output],
        executable = patchelf_bin,
        inputs = inputs,
        arguments = [args],
    )

    cc_compilation_context = cc_lib[CcInfo].compilation_context

    # Return providers given by `cc_library`  to ensure
    # compatiblity with other rules
    return [
        CcInfo(
            compilation_context = cc_compilation_context,
            linking_context = cc_common.create_linking_context(linker_inputs = depset(direct=[new_linker_input])),
        ),
        DefaultInfo(
            files = depset([lib_output]),
        ),
    ]

patchelf_library = rule(
    implementation = _patchelf_library_impl,
    doc = _patchelf_doc,
    attrs = {
        "lib": attr.label(
            doc = "TODO",
            providers = [CcInfo],
            mandatory = True,
        ),
        "args": attr.string_list(
            mandatory = False,
            allow_empty = True,
            default = [], # default to noop patching
            doc = "TODO",
        ),
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
        ),
    },
    outputs = {
    },
    fragments = ["cpp"],
    toolchains = [
        "//patchelf:patchelf_toolchain",
        "@bazel_tools//tools/cpp:toolchain_type",
    ],
)
