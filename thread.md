# torn:

“Torn” means a write or read that happens in pieces, so another thread could observe a partially updated value.
Example: a 64‑bit value written on a machine that only writes 32 bits at a time. 
If one thread writes the 64‑bit value andanother reads it concurrently without atomicity, the reader might see the high 32 bits from the new value and the low 32 bits from the old value — a “torn” read.

Atomics prevent this for the atomic object itself: the write is all‑or‑nothing as observed by other threads. 
For std::atomic<bool>, the value is tiny so tearing is unlikely even without atomics, but the key guarantee is still: other threads will never observe a partially written atomic value.

# With memory_order_relaxed:                                                                                                  
  - Guarantee: the atomic write itself is not torn; other threads will eventually see true.                                   
  - No guarantee: that any other writes done before the store become visible when another thread reads the flag. The compiler/CPU may reorder those other writes around the atomic store.                                                               
# With stronger orderings (e.g., memory_order_release on store and memory_order_acquire on load):

  - Guarantee: if thread A writes some data, then does store(true, release), and thread B does load(acquire) and sees true,
    then B is guaranteed to see all those prior writes from A.

So here, the “synchronization guarantee” is about visibility/order of other memory, not about the flag itself. 
If the flag is just a signal and there’s no dependent data, relaxed is fine. 
If other data must be observed consistently when the flag is seen, you need release/acquire (or seq_cst).


# Here’s a concrete case where ordering is not preserved with memory_order_relaxed:                                                                                                                                
 Key idea: relaxed atomics only make the atomic itself safe. They do not force other memory operations to become visible before or after
  the atomic.

  Why this happens

  - Compiler reordering: The compiler can move ordinary loads/stores across a relaxed atomic because it doesn’t create a synchronization
    barrier.
  - CPU reordering: Even if the compiler keeps the order, the CPU can make the atomic visible to other cores before earlier writes are
    visible (store buffers, cache coherence delays).

  Concrete timeline example
  

  Shared variables:
  
```
  int data = 0;
  std::atomic<bool> ready{false};

  Thread A:

  data = 42;                                  // 1
  ready.store(true, std::memory_order_relaxed); // 2

  Thread B:

  if (ready.load(std::memory_order_relaxed)) { // 3
    printf("%d\n", data);                      // 4
  }
```

  What you might expect: if B sees ready == true, it prints 42.

  What can actually happen with relaxed ordering:

  1. Thread A writes data = 42, but that write is still in A’s store buffer and not yet visible to B.
  2. The atomic store to `ready` becomes visible to B first.
  3. Thread B sees ready == true.
  4. Thread B reads data from its cache and still sees 0.

  So B prints 0 even though it saw the flag set.

  How to enforce order

  Use release/acquire:

  Thread A:

  data = 42;
  ready.store(true, std::memory_order_release);

  Thread B:

  if (ready.load(std::memory_order_acquire)) {
    printf("%d\n", data); // guaranteed 42
  }

  Release/acquire creates a happens-before relationship: if B sees the flag as true, it must also see all prior writes done by A.


