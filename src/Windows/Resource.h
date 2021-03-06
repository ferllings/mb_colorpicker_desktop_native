#pragma once

#define RES_PNG_FILE 256

#define RES_INDEX_FOR_Circle_Mask 0x0001

#ifndef RC_INVOKED

#define WIN32_LEAN_AND_MEAN

#include <Windows.h>
#include <gdiplus.h>


Gdiplus::Bitmap* LoadBitmapFromResPNG(HINSTANCE hInstance, const WORD res_id)
{
    Gdiplus::Bitmap* bitmap = nullptr;

    auto hResource = ::FindResource(hInstance, \
                                    MAKEINTRESOURCE(res_id),
                                    MAKEINTRESOURCE(RES_PNG_FILE) );

    auto resSize = ::SizeofResource(hInstance, hResource);

    auto hBuffer = ::GlobalAlloc(GMEM_MOVEABLE, resSize);
    auto pBuffer = ::GlobalLock(hBuffer);

    IStream* pStream = NULL;
    ::CreateStreamOnHGlobal(hBuffer, FALSE, &pStream);

    auto pResourceData = ::LockResource(::LoadResource(hInstance, hResource));
    ::CopyMemory(pBuffer, pResourceData, resSize);

    bitmap = Gdiplus::Bitmap::FromStream(pStream);

    pStream->Release();
    ::GlobalUnlock(hBuffer);
    ::GlobalFree(hBuffer);

    return bitmap;
}

#endif // RC_INVOKED
