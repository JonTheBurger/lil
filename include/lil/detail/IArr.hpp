#pragma once

#include <stddef.h>
#include <stdint.h>

namespace lil {
template <typename TDerived, typename T>
class IArr {
public:
  using value_type      = T;
  using size_type       = size_t;
  using difference_type = ptrdiff_t;
  using reference       = value_type&;
  using const_reference = const value_type&;
  using pointer         = value_type*;
  using const_pointer   = const value_type*;
  using iterator        = pointer;
  using const_iterator  = const_pointer;
  //  using reverse_iterator       = std::reverse_iterator<iterator>;
  //  using const_reverse_iterator = std::reverse_iterator<const_iterator>;

  constexpr bool empty() const noexcept { return size() == 0; }

  constexpr reference       operator[](size_type i) noexcept { return data()[i]; }
  constexpr const_reference operator[](size_type i) const noexcept { return data()[i]; }

  constexpr reference       at(size_type i) { return const_cast<reference>(static_cast<const IArr*>(this)->at(i)); }
  constexpr const_reference at(size_type i) const
  {
    //    XLU_ASSERT(i < size(), Error::OUT_OF_RANGE);
    return data()[i];
  }

  constexpr reference       front() { return const_cast<reference>(static_cast<const IArr*>(this)->front()); }
  constexpr const_reference front() const
  {
    //    XLU_ASSERT(!empty(), Error::OUT_OF_RANGE);
    return data()[0];
  }
  constexpr reference       back() { return const_cast<reference>(static_cast<const IArr*>(this)->back()); }
  constexpr const_reference back() const
  {
    //    XLU_ASSERT(!empty(), Error::OUT_OF_RANGE);
    return data()[size()];
  }

  constexpr iterator       begin() noexcept { return &data()[0]; }
  constexpr const_iterator begin() const noexcept { return &data()[0]; }
  constexpr const_iterator cbegin() const noexcept { return &data()[0]; }
  constexpr iterator       end() noexcept { return &data()[size()]; }
  constexpr const_iterator end() const noexcept { return &data()[size()]; }
  constexpr const_iterator cend() const noexcept { return &data()[size()]; }
  //  constexpr reverse_iterator       rbegin() noexcept { return reverse_iterator(end()); }
  //  constexpr const_reverse_iterator rbegin() const noexcept { return const_reverse_iterator(end()); }
  //  constexpr const_reverse_iterator crbegin() const noexcept { return const_reverse_iterator(end()); }
  //  constexpr reverse_iterator       rend() noexcept { return reverse_iterator(begin()); }
  //  constexpr const_reverse_iterator rend() const noexcept { return const_reverse_iterator(begin()); }
  //  constexpr const_reverse_iterator crend() const noexcept { return const_reverse_iterator(begin()); }

private:
  constexpr size_type     size() const noexcept { return static_cast<const TDerived*>(this)->size(); }
  constexpr pointer       data() noexcept { return static_cast<TDerived*>(this)->data(); }
  constexpr const_pointer data() const noexcept { return static_cast<const TDerived*>(this)->data(); }
};
}  // namespace lil
