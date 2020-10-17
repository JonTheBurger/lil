#[=======================================================================[.rst:
TempDir
-------

Finds the host build environment's platform specific temporary directory. Generally builds should prefer rooting
temporary files under :variable:`CMAKE_BINARY_DIR`, but some time-intensive tasks that can be shared across builds such
as tarball downloads could make effective use of the system's temp dir.

Example Usages:

.. code-block:: cmake

  include(TempDir)
  temp_dir(tmp)

  if (NOT EXISTS "${tmp}/bigfile.tar.gz")
    file(DOWNLOAD "https://mycompany/files/bigfile.tar.gz" "${tmp}/bigfile.tar.gz")
  endif()

  if (NOT EXISTS "${CMAKE_BINARY_DIR}/bigfile.tar.gz")
    file(COPY "${tmp}/bigfile.tar.gz" DESTINATION "${CMAKE_BINARY_DIR}")
    execute_process(COMMAND "${CMAKE_COMMAND} -E tar xf ${CMAKE_BINARY_DIR}/bigfile.tar.gz")
  endif()

Functions
^^^^^^^^^

.. command:: temp_dir
  Sets ``VAR`` to the host system's temporary directory.

  Signatures::

    temp_dir(<VAR>)

#]=======================================================================]
function(temp_dir VAR)
  if (WIN32)
    set(tmpdir "$ENV{TMP}")
  else()
    set(tmpdir "$ENV{TMPDIR}")
  endif()
  if (NOT tmpdir)
    set(tmpdir "/tmp")
  endif()
  set(${VAR} ${tmpdir} PARENT_SCOPE)
endfunction()
