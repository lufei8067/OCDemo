//
//  ODVertexAttribArrayBuffer.m
//  OCDemo01
//
//  Created by lu on 2021/9/16.
//  Copyright © 2021 lu. All rights reserved.
//

#import "ODVertexAttribArrayBuffer.h"


@interface ODVertexAttribArrayBuffer ()

@property (nonatomic, assign) GLuint glName;
@property (nonatomic, assign) GLsizeiptr bufferSizeBytes;
@property (nonatomic, assign) GLsizei stride;

@end


@implementation ODVertexAttribArrayBuffer

- (void)dealloc {
    if (_glName != 0) {
        glDeleteBuffers(1, &_glName);
        _glName = 0;
    }
}

- (id)initWithAttribStride:(GLsizei)stride
          numberOfVertices:(GLsizei)count
                      data:(const GLvoid *)data
                     usage:(GLenum)usage {
    self = [super init];
    if (self) {
        _stride = stride;
        _bufferSizeBytes = stride * count;
        glGenBuffers(1, &_glName);
        glBindBuffer(GL_ARRAY_BUFFER, _glName);
        glBufferData(GL_ARRAY_BUFFER, _bufferSizeBytes, data, usage);
    }
    return self;
}

- (void)prepareToDrawWithAttrib:(GLuint)index
            numberOfCoordinates:(GLint)count
                   attribOffset:(GLsizeiptr)offset
                   shouldEnable:(BOOL)shouldEnable {
    glBindBuffer(GL_ARRAY_BUFFER, self.glName);
    if (shouldEnable) {
        glEnableVertexAttribArray(index);
    }
    glVertexAttribPointer(index, count, GL_FLOAT, GL_FALSE, self.stride, NULL + offset);
}

- (void)drawArrayWithMode:(GLenum)mode
         startVertexIndex:(GLint)first
         numberOfVertices:(GLsizei)count {
    glDrawArrays(mode, first, count);
}

- (void)updateDataWithAttribStride:(GLsizei)stride
                  numberOfVertices:(GLsizei)count
                              data:(const GLvoid *)data
                             usage:(GLenum)usage {
    self.stride = stride;
    self.bufferSizeBytes = stride * count;
    glBindBuffer(GL_ARRAY_BUFFER, self.glName);
    glBufferData(GL_ARRAY_BUFFER, self.bufferSizeBytes, data, usage);
}



@end
