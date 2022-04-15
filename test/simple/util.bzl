load("//patchelf:patchelf.bzl", "patchelf_print")
load("@bazel_skylib//rules:diff_test.bzl", "diff_test")

def test_patchelf_print(name, args, src):
    print_output = name + ".txt"
    patchelf_print(
        name = print_output,
        args = args,
        src = src,
    )

    diff_test(
        name = name,
        file1 = print_output,
        file2 = ":data",
    )