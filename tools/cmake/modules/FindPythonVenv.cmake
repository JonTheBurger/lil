set(PythonVEnv_DIR ${PROJECT_BINARY_DIR}/.venv)
find_program(HOST_PYTHON_EXECUTABLE
  NAMES
    python3 python
)
execute_process(COMMAND "${HOST_PYTHON_EXECUTABLE}" -m venv "${PythonVEnv_DIR}")

set(Python_EXECUTABLE "${PythonVEnv_DIR}/bin/python" CACHE STRING "")
set(PYTHON_EXECUTABLE "${PythonVEnv_DIR}/bin/python" CACHE STRING "")
find_package(Python)
