#include <stdio.h>
#include <pthread.h>

#include "threaded_hello.h"

static void *print_hello_routine(void *id_ptr)
{
  printf("Hello from thread #%i\n", *(int *)id_ptr);
  return NULL;
}

int print_hello()
{
  int id1 = 0, id2 = 1;
  pthread_t thread;
  print_hello_routine(&id1);

  if(pthread_create(&thread, NULL, print_hello_routine, &id2))
    return 1;

  if(pthread_join(thread, NULL))
    return 2;

  return 0;
}
