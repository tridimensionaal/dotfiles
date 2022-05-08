#!/usr/bin/python3
import re
from abc import ABC


class File(ABC):
    def __init__(self, name: str, file: str, regex_str):
        self.name = name
        regex_str = re.compile(regex_str)
        self.get_list_of_plugins(file, regex_str)
        self.get_names()

    def read_file(self, name: str) -> list[str]:
        with open(f"./{name}", 'r') as f:
            lines = f.readlines()
        return lines

    def get_list_of_plugins(self, name: str, regular_exp):
        lines = self.read_file(name)
        self.raw_plugins = list(filter(regular_exp.match, lines))

    def get_names(self):
        raw_names = list(
                map(
                    lambda x: re.search("'[^'/]+/[^'/]+'", x).group(0),
                    self.raw_plugins
                    )
                )
        raw_names = list(map(lambda x: x.replace("'", ""), raw_names))
        self.plugins = list(map(lambda x: x.split("/"), raw_names))


class Vim(File):
    def __init__(self):
        super().__init__("Vim", ".vimrc", "^Plugin '[^'/]+/[^'/]+'.*\n$")


class NeoVim(File):
    def __init__(self):
        super().__init__("NeoVim", "init.vim", "^Plug '[^'/]+/[^'/]+'.*\n$")


class Readme:
    def __init__(self, files: list):
        self.files = files
        self.create_readme()
        self.save_readme()

    def create_readme(self):
        self.text = "# DotFiles\n\n"

        for file in self.files:
            self.text += f"## {file.name}\n\n### Plugins\n"

            for plugin in file.plugins:
                self.text += f" - ### [{plugin[1]}](https://github.com/{plugin[0]}/{plugin[1]})\n"

            self.text += "\n"

    def save_readme(self):
        with open("README.md", 'w') as f:
            f.write(self.text)


def main():
    Readme([Vim(), NeoVim()])


if __name__ == "__main__":
    main()
