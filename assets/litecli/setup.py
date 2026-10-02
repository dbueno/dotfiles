from setuptools import setup


setup(
    name="litecli-tinted-style",
    version="1.0",
    py_modules=["tinted_style"],
    entry_points={"pygments.styles": ["tinted = tinted_style:TintedStyle"]},
)
