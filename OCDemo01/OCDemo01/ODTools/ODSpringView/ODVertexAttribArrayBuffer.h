//
//  ODVertexAttribArrayBuffer.h
//  OCDemo01
//
//  Created by lu on 2021/9/16.
//  Copyright © 2021 lu. All rights reserved.
//

#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ODVertexAttribArrayBuffer : NSObject


//初始化缓冲区
- (id)initWithAttribStride:(GLsizei)stride
          numberOfVertices:(GLsizei)count
                      data:(const GLvoid *)data
                     usage:(GLenum)usage;
//准备绘制(打开通道，以及传递属性)
- (void)prepareToDrawWithAttrib:(GLuint)index
            numberOfCoordinates:(GLint)count
                   attribOffset:(GLsizeiptr)offset
                   shouldEnable:(BOOL)shouldEnable;
//绘制
- (void)drawArrayWithMode:(GLenum)mode
         startVertexIndex:(GLint)first
         numberOfVertices:(GLsizei)count;

//更新(重新开辟缓冲区)
- (void)updateDataWithAttribStride:(GLsizei)stride
                  numberOfVertices:(GLsizei)count
                              data:(const GLvoid *)data
                             usage:(GLenum)usage;


@end

NS_ASSUME_NONNULL_END
