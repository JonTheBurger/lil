# Doxygen
find_package(Doxygen)
set(DOXYGEN_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/docs)
configure_file(${PROJECT_SOURCE_DIR}/docs/Doxyfile.in ${DOXYGEN_OUTPUT_DIRECTORY}/Doxyfile)
# TODO: custom target DEPENDS on custom command that generates Doxyfile, use output as stamp
add_custom_target(${PROJECT_NAME}.doxygen.xml
  COMMAND
    Doxygen::doxygen ${PROJECT_BINARY_DIR}/docs/Doxyfile --verbose
  WORKING_DIRECTORY
    ${PROJECT_BINARY_DIR}/docs
)

# Sphinx
find_package(PythonVEnv)
add_python_venv()
add_python_venv_requirements(FILE ${PROJECT_SOURCE_DIR}/tools/cmake/docs/requirements.txt)
add_custom_target(.venv.pipfreeze
  COMMAND PythonVEnv::.venv::Interpreter -m pip freeze
)

configure_file(${PROJECT_SOURCE_DIR}/docs/source/conf.py ${DOXYGEN_OUTPUT_DIRECTORY}/source/conf.py)
configure_file(${PROJECT_SOURCE_DIR}/docs/source/index.rst ${DOXYGEN_OUTPUT_DIRECTORY}/source/index.rst)
add_python_venv_requirements(FILE ${PROJECT_SOURCE_DIR}/docs/source/requirements.txt)
add_custom_target(${PROJECT_NAME}.sphinx.pip_install
  COMMAND
    PythonVEnv::.venv::Interpreter -m pip install -r ${PROJECT_SOURCE_DIR}/tools/python/requirements.txt
)
add_custom_target(${PROJECT_NAME}.sphinx.breathe_apidocs
  COMMAND
    breathe-apidoc -o ${DOXYGEN_OUTPUT_DIRECTORY}/source ${DOXYGEN_OUTPUT_DIRECTORY}/xml
)
add_custom_target(${PROJECT_NAME}.sphinx
  COMMAND
    PythonVEnv::.venv::Interpreter -m sphinx -b html ${DOXYGEN_OUTPUT_DIRECTORY}/source ${DOXYGEN_OUTPUT_DIRECTORY}/sphinx
  WORKING_DIRECTORY
    ${DOXYGEN_OUTPUT_DIRECTORY}
)
add_dependencies(${PROJECT_NAME}.sphinx
  ${PROJECT_NAME}.sphinx.pip_install
  ${PROJECT_NAME}.doxygen.xml
  ${PROJECT_NAME}.sphinx.breathe_apidocs
)
