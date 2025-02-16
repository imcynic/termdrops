from setuptools import setup, find_packages

setup(
    name="termdrops",
    version="0.1.0",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    install_requires=[
        'venv',           # For creating virtual environments
        'pip>=21.0',      # For package management
        'setuptools',     # For package installation
        'wheel',          # For building wheel distributions
        'blessed',        # For terminal colors and keyboard input
        'colorama',       # For Windows color support
        'pynput',         # For keyboard input handling
        'python-dotenv',  # For environment variables
    ],
    entry_points={
        'console_scripts': [
            'termdrops=termdrops.__main__:main',
        ],
    },
    author="Cynic + Lukanbot",
    author_email="banner94@outlook.com",
    description="A terminal-based game that runs in both PowerShell and Unix terminals",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    url="https://github.com/yourusername/termdrops",
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.7",
)
