#pragma once

namespace lil {
enum Err {
  NONE  = 0x000,  ///< No error, continue as normal.
  RETRY = 0x001,  ///< Operation incomplete, retry.

  UNKNOWN      = 0x002,  ///< An unknown error has occurred; system may be unstable.
  KERNEL_PANIC = 0x003,  ///< Kernel error has occurred; abort operation.

  INVALID_ARGUMENT = 0x004,  ///< Supplied argument violates required preconditions. Likely programmer or input sanitization error.
  ILLEGAL_STATE    = 0x005,  ///< System is in a state that should not be possible.
  INVALID_FORMAT   = 0x006,  ///< Format is incorrect. E.g. format string, export format, etc.
  ENCODE_FAIL      = 0x007,  ///< Protocol data translation failed. Invalid input supplied.
  DECODE_FAIL      = 0x008,  ///< Protocol data translation failed. Invalid input supplied.

  OPERATION_FAILED      = 0x009,  ///< Operation has failed in unspecified manner.
  OPERATION_TIMED_OUT   = 0x00A,  ///< Operation has not completed in the allotted time.
  OPERATION_ABORTED     = 0x00B,  ///< Operation has been aborted before its successful completion.
  OPERATION_UNSUPPORTED = 0x00C,  ///< Attempted to perform operation that cannot be properly handled.

  OUT_OF_RANGE     = 0x00D,  ///< Value or address outside of valid bounds.
  NULL_POINTER     = 0x00E,  ///< Null pointer dereference attempt. Segmentation fault would have occurred.
  DATA_CORRUPTED   = 0x00F,  ///< Sentinel or other values do not match expected results, RAM/Flash check failure, etc.
  BAD_ALLOC        = 0x010,  ///< Allocation failed. Out of heap memory, pool/arena exhausted, etc.
  BAD_ALIGN        = 0x011,  ///< Value is not on properly aligned address.
  ACCESS_VIOLATION = 0x012,  ///< Attempted to access invalid address. E.g. memory mapped region, unwritable memory, wrong I2C address,

  CHECKSUM = 0x013,  ///< Checksum mismatch. E.g. bus/net protocol, hardware checks, etc.
  PARITY   = 0x014,  ///< Parity check failed.
  NAK      = 0x015,  ///< NAK received.
  FRAMING  = 0x016,  ///< Framing error detected.
  NOISE    = 0x017,  ///< Bus noise disrupting communication.

  RESOURCE_UNINITIALIZED = 0x018,  ///< Attempted to use resource before it was initialized. E.g. missing init() call, not initializing a bus transaction, etc.
  RESOURCE_FULL          = 0x019,  ///< There is no more space for storage. E.g. NVM exhausted, FIFO full, Message Queue at capacity, etc.
  RESOURCE_EMPTY         = 0x01A,  ///< There are no items to process.
  RESOURCE_BUSY          = 0x01B,  ///< The resource is being used by someone else and is unavailable.

  DIVIDE_BY_ZERO = 0x01C,  ///< Illegal division by zero.
  MATH_OVERFLOW  = 0x01D,  ///< Mathematical value overflows in manner not supported by application.
  MATH_UNDERFLOW = 0x01E,  ///< Mathematical value underflows in manner not supported by application.

  TX_FAIL               = 0x01F,  ///< Transmission failed for an unspecified reason.
  RX_FAIL               = 0x020,  ///< Receiving failed for an unspecified reason.
  ENDPOINT_UNREACHABLE  = 0x021,  ///< Could not establish a connection.
  COMMUNICATION_DROPPED = 0x022,  ///< A previously successful communication has been terminated.

  HANDSHAKE_FAILED  = 0x023,  ///< Communications OK, but
  PERMISSION_DENIED = 0x024,  ///< A procedure could not be run due to insufficient permissions.
  KEY_REJECTED      = 0x025,  ///< Some key was not valid. E.g. invliad key/password/hash/token.
  KEY_EXPIRED       = 0x026,  ///< Previously acceptable key/token etc. is no longer valid.

  METL_MAX,            ///< Last contiguous enum for currently implemented error codes. Good for an array max, bounds check, etc.
  USER_ERROR = 0x100,  ///< First enum value that can be used for application specific errors.
  ERROR_MAX  = 0x200,  ///< Maximum number of error codes that may ever be allocated.
};

static const char* ToString(Err err);
}  // namespace lil
