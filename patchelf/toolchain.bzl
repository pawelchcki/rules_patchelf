"""A module defining toolchain information about the patchelf rules"""

def _patchelf_toolchain_impl(ctx):
    """The implementation of the `patchelf_toolchain` rule

    Args:
        ctx (ctx): The rule's context object.

    Returns:
        list: A list containing a ToolchainInfo provider.
    """
    return [platform_common.ToolchainInfo(
        patchelf = ctx.executable.patchelf,
    )]

patchelf_toolchain = rule(
    doc = "The tools required for the patchelf rules.",
    implementation = _patchelf_toolchain_impl,
    attrs = {
        "patchelf": attr.label(
            doc = "The label of a `patchelf` executable.",
            executable = True,
            cfg = "exec",
        ),
    },
)
