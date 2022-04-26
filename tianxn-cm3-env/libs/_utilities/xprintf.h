/*------------------------------------------------------------------------/
/  Universal string handler for user console interface
/-------------------------------------------------------------------------/
/
/  Copyright (C) 2011, ChaN, all right reserved.
/
/ * This software is a free software and there is NO WARRANTY.
/ * No restriction on use. You can use, modify and redistribute it for
/   personal, non-profit or commercial products UNDER YOUR RESPONSIBILITY.
/ * Redistributions of source code must retain the above copyright notice.
/
/-------------------------------------------------------------------------*/

#ifndef __XPRINTF_H
#define __XPRINTF_H

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

void xputc (char c);
void xputs (const char* str);
void xprintf (const char* fmt, ...);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /*__XPRINTF_H */