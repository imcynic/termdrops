from setuptools import setup, find_packages

setup(
    name="termdrops",
    version="0.1.0",
    package_dir={"": "src"},  # Add this line to specify src directory
    packages=find_packages(where="src"),  # Update this to look in src
    install_requires=[
        "click>=8.0.0",
        "requests>=2.25.0",
        "rich>=10.0.0",
        "python-dotenv>=0.19.0",
    ],
    entry_points={
        "console_scripts": [
            "termdrops=termdrops.cli:main",
        ],
    },
    author="LT Lives",
    author_email="your.email@example.com",
    description="TermDrops CLI - Collect pets while using your terminal",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    url="https://github.com/imcynic/termdrops",
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.7",
)
