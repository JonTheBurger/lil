#pragma once

namespace lil {
/** @brief A pair of values that represents a contiguous, inclusive range.
 * @tparam A literal type that supports noexcept default ctor, copy ctor, and operators <, ==, +, -, and /.
 */
template <typename T>
class Interval final {
public:
  using value_type = T;  ///< STL style type alias.

  T min;  ///< Minimum inclusive boundary.
  T max;  ///< Maximum inclusive boundary.

  /** @brief Constructs an Interval that accepts a single value of default constructed T. */
  constexpr Interval() noexcept
      : min()
      , max()
  {
  }

  /** @brief Constructs an Interval from the provided values.
   * @param min Inclusive lower bound of range, selected as min of the 2 args.
   * @param max Inclusive upper bound of range, selected as max of the 2 args.
   */
  constexpr Interval(T min, T max) noexcept
      : min(minimum(min, max))
      , max(maximum(min, max))
  {
  }

  /** @brief Returns value, if within this Interval, else the boundary value is closes to. */
  constexpr T clip(const T value) const noexcept
  {
    return minimum(max, maximum(min, value));
  }

  /** @brief Determines if the value is between the inclusive range [min, max]. */
  constexpr bool inRange(T value) const noexcept
  {
    return clip(value) == value;
  }

  /** @brief Returns value, if outside this Interval, else the deadband value. */
  constexpr T deadband(const T value, const T deadband) const noexcept
  {
    T adjusted = value;

    if (inRange(value))
    {
      adjusted = deadband;
    }

    return adjusted;
  }

  /** @brief Returns value, if outside this Interval, else the midpoint. */
  constexpr T deadband(const T value) const noexcept
  {
    return deadband(value, mid());
  }

  /** @brief Returns the midpoint of the Interval. */
  constexpr T mid() const noexcept
  {
    return (min + max) / 2;
  }

  /** @brief Returns the difference between max and min. min + length() == max. */
  constexpr T length() const noexcept
  {
    return max - min;
  }

  /** @brief Constructs an Interval that accepts values that would only be accepted in both lhs and rhs. Inner join.
   * @warning If lhs and rhs do not overlap, the returned Interval spans the 2 inner boundaries, e.g. ([1, 2], [3, 4]) -> [2, 3].
   */
  static constexpr Interval intersect(const Interval& lhs, const Interval& rhs) noexcept
  {
    auto min = maximum(lhs.min, rhs.min);
    auto max = minimum(lhs.max, rhs.max);
    return Interval{ min, max };
  }

  /** @brief Constructs an Interval that accepts any value that would only be accepted in either lhs and rhs. Full outer join.
   * @warning If lhs and rhs do not overlap, the returned Interval spans the 2 outer boundaries, e.g. ([1, 2], [3, 4]) -> [1, 4].
   */
  static constexpr Interval uunion(const Interval& lhs, const Interval& rhs) noexcept
  {
    auto min = minimum(lhs.min, rhs.min);
    auto max = maximum(lhs.max, rhs.max);
    return Interval{ min, max };
  }

  /** @brief Checks if the two Intervals are equivalent. */
  bool operator==(const Interval& other) const noexcept
  {
    return (min == other.min) && (max == other.max);
  }

  /** @brief Checks if the two Intervals are not equivalent. */
  bool operator!=(const Interval& other) const noexcept
  {
    return !(*this == other);
  }
};

/** @brief Returns the lesser of 2 values; rhs is returned in case of tie. */
template <typename T>
static constexpr T minimum(T lhs, T rhs)
{
  return lhs < rhs ? lhs : rhs;
}

/** @brief Returns the greater of 2 values; rhs is returned in case of tie. */
template <typename T>
static constexpr T maximum(T lhs, T rhs)
{
  return lhs > rhs ? lhs : rhs;
}

}  // namespace lil
