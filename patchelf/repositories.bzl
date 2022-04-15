load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def rules_patchelf_dependencies():
    maybe(
        http_archive,
        name = "rules_cc",
        urls = ["https://github.com/bazelbuild/rules_cc/releases/download/0.0.1/rules_cc-0.0.1.tar.gz"],
        sha256 = "4dccbfd22c0def164c8f47458bd50e0c7148f3d92002cdb459c2a96a68498241",
    )

    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.2.1/bazel-skylib-1.2.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.2.1/bazel-skylib-1.2.1.tar.gz",
        ],
        sha256 = "f7be3474d42aae265405a592bb7da8e171919d74c16f082a5457840f06054728",
    )

    maybe(
        http_archive,
        name = "nixos_patchelf",
        build_file = "@//patchelf:BUILD.patchelf.bazel",
        strip_prefix = "patchelf-0.14.5",
        urls = ["https://github.com/NixOS/patchelf/releases/download/0.14.5/patchelf-0.14.5.tar.gz"],
        sha256 = "113ada3f1ace08f0a7224aa8500f1fa6b08320d8f7df05ff58585286ec5faa6f",
    )

    native.register_toolchains("//patchelf:default_patchelf_toolchain")
