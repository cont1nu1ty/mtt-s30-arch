#include <stdio.h>
#include <linux/watchdog.h>
int main(void) {
 printf("%lu %lu %lu %lu %lu %lu %zu\n", (unsigned long)WDIOC_GETSUPPORT,
 (unsigned long)WDIOC_SETOPTIONS,(unsigned long)WDIOC_KEEPALIVE,
 (unsigned long)WDIOC_SETTIMEOUT,(unsigned long)WDIOC_GETTIMEOUT,
 (unsigned long)WDIOC_GETTIMELEFT,sizeof(struct watchdog_info));
}
