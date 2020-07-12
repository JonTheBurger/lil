#pragma once

//#include <xlu/macro.hpp>
#include <lil/Err.hpp>

#ifndef XLU_FILENAME
#  define XLU_FILENAME __FILE__
#endif

namespace lil {
//#if XLU_IS_HOSTED
//class Exception : public std::exception {
//public:
//  Exception(Error::Code err, const char* expression, const char* fileLine);
//
//  inline const char* what() const noexcept override { return _what.c_str(); }
//  inline Error::Code code() const noexcept { return _err; }
//
//private:
//  std::string _what;
//  Error::Code _err;
//};
//#endif

void AssertFail(Err err, const char* expression, const char* fileLine) noexcept(false);
}  // namespace lil

#ifndef XLU_ASSERT
#  define XLU_ASSERT(expr, err) \
    if (!(expr)) { xlu::AssertFail(err, #expr, XLU_FILENAME ":" XSTRINGIFY(__LINE__)); }
#endif  // XLU_ASSERT
