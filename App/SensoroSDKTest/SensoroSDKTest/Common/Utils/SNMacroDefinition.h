//
//  SNMacroDefinition.h
//  WanDaLive
//
//  Created by Jarvis on 13-12-3.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#ifndef WanDaLive_SNMacroDefinition_h
#define WanDaLive_SNMacroDefinition_h

//-------------------------获取设备大小-------------------------
//NavBar高度
#define NavigationBar_HEIGHT 44
//获取屏幕 宽度、高度
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
//-------------------------获取设备大小-------------------------


//-------------------------图片-------------------------
//读取本地图片
#define LOADIMAGE(file,ext) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]
//定义UIImage对象
#define IMAGE(A) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:A ofType:nil]]
//定义UIImage对象
#define ImageNamed(_pointer) [UIImage imageNamed:[UIUtil imageName:_pointer]]
//获取RGBA颜色
#define RGBA(r, g, b, a)    [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b)          RGBA(r,g,b,1.0f)
//-------------------------图片-------------------------


//-------------------------颜色-------------------------
//获取RGBA颜色
#define RGBA(r, g, b, a)    [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
//获取RGB颜色
#define RGB(r,g,b)          RGBA(r,g,b,1.0f)
//-------------------------颜色-------------------------


#endif
