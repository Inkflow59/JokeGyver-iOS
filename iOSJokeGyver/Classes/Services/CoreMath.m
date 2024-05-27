#import "CoreMath.h"
#import "CServices.h"
#include <cstring>

//Carmacks 1/squareRoot
float Q_rsqrt( float number )
{
	int i;
	float x2, y;
	const float threehalfs = 1.5F;
	x2 = number * 0.5F;
	y  = number;
	i  = * ( int * ) &y;
	i  = 0x5f3759df - ( i >> 1 );
	y  = * ( float * ) &i;
	y  = y * ( threehalfs - ( x2 * y * y ) );
	return y;
}


float degreesToRadians(float degrees)
{
	return degrees * (float)M_PI/180.0f;
}

float radiansToDegrees(float radians)
{
	float ret = radians * 180.0f/(float)M_PI;
	if (ret < 0)
		return 360+ret;
	else
		return ret;
}

//////////////
//Matrix 3x3//
//////////////

bool Mat3f::operator==(const Mat3f &rhs) const{return memcmp(this, &rhs, sizeof(Mat3f))==0;}
bool Mat3f::operator!=(const Mat3f &rhs) const{return memcmp(this, &rhs, sizeof(Mat3f))!=0;}

Mat3f Mat3f::identity()
{
	Mat3f ret = {	1,0,0,
					0,1,0,
					0,0,1};
	return ret;
}

Mat3f Mat3f::zero()
{
	Mat3f ret = {0,0,0,0,0,0,0,0,0};
	return ret;
}

Mat3f Mat3f::identityFlippedY()
{
	Mat3f ret = {	1,	0,	0,
					0, -1,	0,
					0,	1,	1};
	return ret;
}

Mat3f Mat3f::translationMatrix(float x, float y, float z)
{
	Mat3f ret = {	1,0,0,
					0,1,0,
					x,y,z};
	return ret;
}
Mat3f Mat3f::translationMatrix(float x, float y)
{
	Mat3f ret = {	1,0,0,
					0,1,0,
					x,y,1};
	return ret;
}
Mat3f Mat3f::scaleMatrix(float x, float y, float z)
{
	Mat3f ret = {	x,0,0,
					0,y,0,
					0,0,z	};
	return ret;
}
Mat3f Mat3f::scaleMatrix(float x, float y)
{
	Mat3f ret = {	x,0,0,
					0,y,0,
					0,0,1	};
	return ret;
}

Mat3f Mat3f::objectMatrix(const Vec2f &position, const Vec2f &size, const Vec2f &center)
{
	Mat3f ret = {
		size.x,					0,						0,
		0,						size.y,					0,
		position.x-center.x,	position.y-center.y,    1
	};
	return ret;
}

Mat3f Mat3f::objectRotationMatrix(const Vec2f &position, const Vec2f &size, const Vec2f &scale, const Vec2f &center, float angle)
{
	//Concatenation of several transformations: scale to object size, adjust hotspot, scale, rotation and translate
	float radians = -angle * 0.0174532925f;
	float sino = sinf(radians);
	float coso = cosf(radians);
	float sxCoso = scale.x * coso;
	float syCoso = scale.y * coso;
	float sxSino = scale.x * sino;
	float sySino = scale.y * sino;

	Mat3f ret = {
		size.x*sxCoso,										size.x*sxSino,										0,
		-size.y*sySino,										size.y*syCoso,										0,
		position.x - center.x*sxCoso + center.y*sySino,		position.y - center.y*syCoso - center.x*sxSino,		1
	};
	return ret;
}


Mat3f Mat3f::textureMatrix(float x, float y, float w, float h, float textureWidth, float textureHeight)
{
	float invW = 1.0f/textureWidth;
	float invH = 1.0f/textureHeight;

	x *= invW;
	y *= invH;
	w *= invW;
	h *= invH;

	Mat3f ret = {	w,		0,		0,
					0,		h,		0,
					x,		y,		1
	};

	return ret;
}

Mat3f Mat3f::textureMatrixFlipped(float x, float y, float w, float h, float o, float textureWidth, float textureHeight)
{
	float invW = 1.0f/textureWidth;
	float invH = 1.0f/textureHeight;

	x *= invW;
	y *= invH;
	w *= invW;
	h *= invH;
	o *= invH;

	Mat3f ret = {	w,		0,		0,
					0,		-h,		0,
					x,		o-y,	1
	};

	return ret;
}

Mat3f Mat3f::orthogonalProjectionMatrix(int x, int y, int w, int h)
{
	float left = x;
	float right = x + w;
	float top = y;
	float bottom = y+h;
	float tx = - (right+left)/(right-left);
	float ty = - (top+bottom)/(top-bottom);

	Mat3f ret = {
		2.0f/(right-left),	0,					0,
		0,					2.0f/(top-bottom),	0,
		tx,					ty,					1
	};
	return ret;
}

// 0 1 2
// 3 4 5
// 6 7 8

Mat3f Mat3f::multiply(Mat3f &a, Mat3f &b)
{
/*
				a	d	g
				b	e	h
				c	f	i

	a	d	g
	b	e	h
	c	f	i

*/

	Mat3f ret;
	ret.a = b.a * a.a + b.d * a.b + b.g * a.c;
	ret.b = b.b * a.a + b.e * a.b + b.h * a.c;
	ret.c = b.c * a.a + b.f * a.b + b.i * a.c;
	ret.d = b.a * a.d + b.d * a.e + b.g * a.f;
	ret.e = b.b * a.d + b.e * a.e + b.h * a.f;
	ret.f = b.c * a.d + b.f * a.e + b.i * a.f;
	ret.g = b.a * a.g + b.d * a.h + b.g * a.i;
	ret.h = b.b * a.g + b.e * a.h + b.h * a.i;
	ret.i = b.c * a.g + b.f * a.h + b.i * a.i;
	return ret;
}

Mat3f Mat3f::multiply(Mat3f &a, Mat3f &b, Mat3f &c, Mat3f &d)
{
	Mat3f first = Mat3f::multiply(a, b);
	Mat3f second = Mat3f::multiply(c, d);
	return Mat3f::multiply(first, second);
}

Mat3f Mat3f::transpose() const
{
	Mat3f ret = {a,d,g,  b,e,h,  c,f,i};
	return ret;
}

float Mat3f::determinant() const
{
	return	a*e*i + b*f*g + c*d*h - c*e*g - b*d*i - a*f*h;
}

Mat3f Mat3f::inverted() const
{
	float invD = 1.0f/this->determinant();
	Mat3f tr;
	tr.a = invD * (e*i - f*h);
	tr.b = invD * (c*h - b*i);
	tr.c = invD * (b*f - c*e);
	tr.d = invD * (f*g - d*i);
	tr.e = invD * (a*i - c*g);
	tr.f = invD * (c*d - a*f);
	tr.g = invD * (d*h - e*g);
	tr.h = invD * (g*b - a*h);
	tr.i = invD * (a*e - b*d);
	return tr;
}

Vec2f Mat3f::transformPoint(Vec2f p) const
{
	return Vec2f(a*p.x + b*p.y + c,
				 d*p.x + e*p.y + f);
}

Mat3f Mat3f::flippedTexCoord(bool flipX, bool flipY)
{
	float iW = a;
	float iH = e;

	float iX = c;
	float iY = f;

	float fX = flipX ? -1 : 1;
	float fY = flipY ? -1 : 1;

	float ftX = flipX ? 1 : 0;
	float ftY = flipY ? 1 : 0;

	Mat3f ret = {
		fX * iW,		0,				0,
		0,				fY * iH,		0,
		ftX*iW + iX,	ftY*iH + iY,	1
	};
	return ret;
}


Mat3f Mat3f::maskspaceToWorldspace(Vec2f position, Vec2f hotspot, Vec2f scale, float angle)
{
	float radians = -angle * 0.0174532925f;
	float cosa = cosf(radians);
	float sina = sinf(radians);
	float sxa = scale.x;
	float sya = scale.y;
	float pxa = position.x;
	float pya = position.y;
	float hxa = hotspot.x;
	float hya = hotspot.y;

	Mat3f ret = {
		cosa*sxa,									sina*sxa,									0,
		-sina*sya,									cosa*sya,									0,
		-cosa*hxa*sxa + hya*sina*sya + pxa,			-cosa*hya*sya - hxa*sina*sxa + pya,			1
	};
	return ret;
}


Mat3f Mat3f::worldspaceToMaskspace(Vec2f position, Vec2f hotspot, Vec2f scale, float angle)
{
	float radians = angle * 0.0174532925f;
	float cosb = cosf(radians);
	float sinb = sinf(radians);
	float sxb = 1.0f/scale.x;
	float syb = 1.0f/scale.y;
	float pxb = position.x;
	float pyb = position.y;
	float hxb = hotspot.x;
	float hyb = hotspot.y;

	Mat3f ret = {
		cosb*sxb,								sinb*syb,										0,
		-sinb*sxb,								cosb*syb,										0,
		-cosb*pxb*sxb + hxb + pyb*sinb*sxb,		-cosb*pyb*syb + hyb - pxb*sinb*syb,				1
	};
	return ret;
}

Mat3f Mat3f::maskspaceToMaskspace(Vec2f positionA, Vec2f hotspotA, Vec2f scaleA, float angleA, Vec2f positionB, Vec2f hotspotB, Vec2f scaleB, float angleB)
{
	float radiansA = -angleA * 0.0174532925f;
	float cosa = cosf(radiansA);
	float sina = sinf(radiansA);
	float sxa = scaleA.x;
	float sya = scaleA.y;
	float pxa = positionA.x;
	float pya = positionA.y;
	float hxa = hotspotA.x;
	float hya = hotspotA.y;

	float radiansB = angleB * 0.0174532925f;
	float cosb = cosf(radiansB);
	float sinb = sinf(radiansB);
	float sxb = 1.0f/scaleB.x;
	float syb = 1.0f/scaleB.y;
	float pxb = positionB.x;
	float pyb = positionB.y;
	float hxb = hotspotB.x;
	float hyb = hotspotB.y;

	Mat3f ret = {
		cosa*cosb*sxa*sxb - sina*sinb*sxa*sxb,
		cosa*sinb*sxa*syb + cosb*sina*sxa*syb,
		0,

		-cosa*sinb*sxb*sya - cosb*sina*sxb*sya,
		cosa*cosb*sya*syb - sina*sinb*sya*syb,
		0,

		cosa*(hya*sinb*sxb*sya - cosb*hxa*sxa*sxb) + cosb*(hya*sina*sya + pxa - pxb)*sxb + hxa*sina*sinb*sxa*sxb + hxb - (pya - pyb)*sinb*sxb,
		cosa*(-cosb*hya*sya*syb - hxa*sinb*sxa*syb) - cosb*(hxa*sina*sxa - pya + pyb)*syb + hya*sina*sinb*sya*syb + hyb + pxa*sinb*syb - pxb*sinb*syb,
		1
	};
	return ret;
}

/////////////////////
//    Matrix 4x4   //
/////////////////////
bool Mat4f::operator==(const Mat4f &rhs) const{return memcmp(this, &rhs, sizeof(Mat4f))==0;}
bool Mat4f::operator!=(const Mat4f &rhs) const{return memcmp(this, &rhs, sizeof(Mat4f))!=0;}

Mat4f Mat4f::identity()
{
    Mat4f ret = {   1,0,0,0,
                    0,1,0,0,
                    0,0,1,0,
                    0,0,0,1};
    return ret;
}

Mat4f Mat4f::zero()
{
    Mat4f ret = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    return ret;
}

Mat4f Mat4f::identityFlippedY()
{
    Mat4f ret = {    1, 0,0,0,
                     0,-1,0,0,
                     0, 1,1,0,
                     0, 0,0,1
    };
    return ret;
}

Mat4f Mat4f::translationMatrix(float x, float y, float z)
{
    Mat4f ret = {       1,0,0,0,
                        0,1,0,0,
                        0,0,1,0,
                        x,y,z,1};
    return ret;
}
Mat4f Mat4f::translationMatrix(float x, float y)
{
    Mat4f ret = {       1,0,0,0,
                        0,1,0,0,
                        0,0,1,0,
                        x,y,1,1};
    return ret;
}
Mat4f Mat4f::scaleMatrix(float x, float y, float z)
{
    Mat4f ret = {       x,0,0,0,
                        0,y,0,0,
                        0,0,z,0,
                        0,0,0,1};
    return ret;
}
Mat4f Mat4f::scaleMatrix(float x, float y)
{
    Mat4f ret = {       x,0,0,0,
                        0,y,0,0,
                        0,0,1,0,
                        0,0,0,1};
    return ret;
}

Mat4f Mat4f::objectMatrix(const Vec2f &position, const Vec2f &size, const Vec2f &center)
{
    Mat4f ret = {
        size.x,                    0,                        0,     0,
        0,                        size.y,                    0,     0,
        position.x-center.x,    position.y-center.y,         0,     0,
        0,                         0,                        0,     1
    };
    return ret;
}

Mat4f Mat4f::objectRotationMatrix(const Vec2f &position, const Vec2f &size, const Vec2f &scale, const Vec2f &center, float angle)
{
    //Concatenation of several transformations: scale to object size, adjust hotspot, scale, rotation and translate
    float radians = -angle * 0.0174532925f;
    float sino = sinf(radians);
    float coso = cosf(radians);
    float sxCoso = scale.x * coso;
    float syCoso = scale.y * coso;
    float sxSino = scale.x * sino;
    float sySino = scale.y * sino;
    
    Mat4f ret = {
        size.x*sxCoso,                                         size.x*sxSino,                                       0,                  0,
        -size.y*sySino,                                        size.y*syCoso,                                       0,                  0,
        position.x - center.x*sxCoso + center.y*sySino,        position.y - center.y*syCoso - center.x*sxSino,      0,                  0,
        0,                                                      0,                                                  0,                  1
    };
    return ret;
}


Mat4f Mat4f::textureMatrix(float x, float y, float w, float h, float textureWidth, float textureHeight)
{
    float invW = 1.0f/textureWidth;
    float invH = 1.0f/textureHeight;
    
    x *= invW;
    y *= invH;
    w *= invW;
    h *= invH;
    
    Mat4f ret = {       w,      0,        0,      0,
                        0,      h,        0,      0,
                        x,      y,        0,      0,
                        0,      0,        0,      1
    };
    
    return ret;
}

Mat4f Mat4f::textureMatrixFlipped(float x, float y, float w, float h, float o, float textureWidth, float textureHeight)
{
    float invW = 1.0f/textureWidth;
    float invH = 1.0f/textureHeight;
    
    x *= invW;
    y *= invH;
    w *= invW;
    h *= invH;
    o *= invH;
    
    Mat4f ret = {   w,         0,        0,     0,
                    0,        -h,        0,     0,
                    x,        o-y,       0,     0,
                    0,         0,        0,     1
    };
    
    return ret;
}

Mat4f Mat4f::orthogonalProjectionMatrix(int x, int y, int w, int h)
{
    float left = x;
    float right = x + w;
    float top = y;
    float bottom = y+h;
    float tx = - (right+left)/(right-left);
    float ty = - (top+bottom)/(top-bottom);
    
    float far = 1.0f;
    float near = -1.0f;
    float tz = - ((far+near)/(far-near));
    
    
    Mat4f ret = {
        2.0f/(right-left),    0,                    0,                      0,
        0,                    2.0f/(top-bottom),    0,                      0,
        0,                    0,                    -2.0f / (far - near),   0,
        tx,                   ty,                  tz,                      1
    };
    
    return ret;
}

// 0 1 2
// 3 4 5
// 6 7 8

Mat4f Mat4f::multiply(Mat4f &a, Mat4f &b)
{
    /*
     a    e    i    m
     b    f    j    n
     c    g    k    o
     d    h    l    p
     
     a    e    i    m
     b    f    j    n
     c    g    k    o
     d    h    l    p
     
     */
    
    Mat4f ret;
    ret.a = a.a*b.a + a.e*b.b + a.i*b.c + a.m*b.d;
    ret.b = a.b*b.a + a.f*b.b + a.j*b.c + a.n*b.d;
    ret.c = a.c*b.a + a.g*b.b + a.k*b.c + a.o*b.d;
    ret.d = a.d*b.a + a.h*b.b + a.l*b.c + a.p*b.d;
    ret.e = a.a*b.e + a.e*b.f + a.i*b.g + a.m*b.h;
    ret.f = a.b*b.e + a.f*b.f + a.j*b.g + a.n*b.h;
    ret.g = a.c*b.e + a.g*b.f + a.k*b.g + a.o*b.h;
    ret.h = a.d*b.e + a.h*b.f + a.l*b.g + a.p*b.h;
    ret.i = a.a*b.i + a.e*b.j + a.i*b.k + a.m*b.l;
    ret.j = a.b*b.i + a.f*b.j + a.j*b.k + a.n*b.l;
    ret.k = a.c*b.i + a.g*b.j + a.k*b.k + a.o*b.l;
    ret.l = a.d*b.i + a.h*b.j + a.l*b.k + a.p*b.l;
    ret.m = a.a*b.m + a.e*b.n + a.i*b.o + a.m*b.p;
    ret.n = a.b*b.m + a.f*b.n + a.j*b.o + a.n*b.p;
    ret.o = a.c*b.m + a.g*b.n + a.k*b.o + a.o*b.p;
    ret.p = a.d*b.m + a.h*b.n + a.l*b.o + a.p*b.p;

    return ret;
}

Mat4f Mat4f::multiply(Mat4f &a, Mat4f &b, Mat4f &c, Mat4f &d)
{
    Mat4f first = Mat4f::multiply(a, b);
    Mat4f second = Mat4f::multiply(c, d);
    return Mat4f::multiply(first, second);
}

Mat4f Mat4f::transpose() const
{
    Mat4f ret = {a,e,i,m,  b,f,j,n,  c,g,k,o,    d,h,l,p};
    return ret;
}

float Mat4f::determinant() const
{
    return    a*f*k*p+a*n*g*l+a*j*o*h-a*n*k*h-a*f*o*l
             -a*j*g*p-e*b*k*p-e*j*o*d-e*n*c*l+e*n*k*d
             +e*b*o*l+e*j*c*p+l*b*g*p+l*f*o*d+l*n*c*h
             +l*n*g*d-l*b*o*h-l*f*c*p-m*b*g*l-m*f*k*d
             -m*j*c*h+m*j*g*d+m*b*k*h+m*f*c*l;
}

Mat4f Mat4f::inverted() const
{
    float invD = 1.0f/this->determinant();
    Mat4f tr;
     
    tr.a = invD * (+f*k*p+j*o*h+n*g*l-n*k*h-j*g*p-f*o*l);
    tr.e = invD * (-e*k*p-l*o*h-m*g*l+m*k*h+l*g*p+e*o*l);
    tr.i = invD * (e*j*p+l*n*h+m*f*l-m*j*h-l*f*p-e*n*l);
    tr.m = invD * (-e*j*o-l*n*g-m*f*k+m*j*g+l*f*o+e*n*k);
    
    tr.b = invD * (-b*k*p-j*o*d-n*c*l+n*k*d+j*c*p+b*o*l);
    tr.f = invD * (a*k*p+l*o*d+m*c*l-m*k*d-l*c*p-a*o*l);
    tr.j = invD * (-a*j*p-l*n*d-m*b*l+m*j*d+l*b*p+a*n*k);
    tr.n = invD * (a*j*o+l*n*c+m*b*k-m*j*c-l*b*o-a*n*k);
    
    tr.c = invD * (b*g*p+f*o*d+m*c*h-n*g*d-f*c*p-b*o*h);
    tr.g = invD * (-a*g*p-e*o*d-m*c*h+m*g*d+e*c*p+a*o*h);
    tr.k = invD * (a*f*p+e*n*d+m*b*h-m*f*d-e*b*p-a*n*h);
    tr.o = invD * (-a*f*o-e*n*c-m*b*g+m*f*c+e*b*o+a*n*g);
    
    tr.d = invD * (-b*g*l-f*k*d-l*c*h+l*f*d+f*c*l+b*k*h);
    tr.h = invD * (a*g*p+e*k*d+l*c*h-l*g*d-e*c*l-a*k*h);
    tr.l = invD * (-a*f*l-e*j*d-l*b*h+l*f*d+e*b*l+a*k*h);
    tr.p = invD * (a*f*k+e*j*d+l*b*g-l*f*c-e*b*k-a*j*g);
    return tr;
}

Vec2f Mat4f::transformPoint(Vec2f p) const
{
    return Vec2f(a*p.x + b*p.y + c + d,
                 e*p.x + f*p.y + g + h);
}

Mat4f Mat4f::flippedTexCoord(bool flipX, bool flipY)
{
    float iW = a;
    float iH = e;
    
    float iX = c;
    float iY = f;
    
    float fX = flipX ? -1 : 1;
    float fY = flipY ? -1 : 1;
    
    float ftX = flipX ? 1 : 0;
    float ftY = flipY ? 1 : 0;
    
    Mat4f ret = {
        fX * iW,        0,                0,    0,
        0,              fY * iH,          0,    0,
        ftX*iW + iX,    ftY*iH + iY,      0,    0,
        0,              0,                0,    1
    };
    return ret;
}


Mat4f Mat4f::maskspaceToWorldspace(Vec2f position, Vec2f hotspot, Vec2f scale, float angle)
{
    float radians = -angle * 0.0174532925f;
    float cosa = cosf(radians);
    float sina = sinf(radians);
    float sxa = scale.x;
    float sya = scale.y;
    float pxa = position.x;
    float pya = position.y;
    float hxa = hotspot.x;
    float hya = hotspot.y;
    
    Mat4f ret = {
        cosa*sxa,                                    sina*sxa,                                 0,    0,
        -sina*sya,                                   cosa*sya,                                 0,    0,
        -cosa*hxa*sxa + hya*sina*sya + pxa,         -cosa*hya*sya - hxa*sina*sxa + pya,        0,    0,
        0,                                          0,                                         0,    1
    };
    return ret;
}


Mat4f Mat4f::worldspaceToMaskspace(Vec2f position, Vec2f hotspot, Vec2f scale, float angle)
{
    float radians = angle * 0.0174532925f;
    float cosb = cosf(radians);
    float sinb = sinf(radians);
    float sxb = 1.0f/scale.x;
    float syb = 1.0f/scale.y;
    float pxb = position.x;
    float pyb = position.y;
    float hxb = hotspot.x;
    float hyb = hotspot.y;
    
    Mat4f ret = {
        cosb*sxb,                                sinb*syb,                                          0,    0,
        -sinb*sxb,                               cosb*syb,                                          0,    0,
        -cosb*pxb*sxb + hxb + pyb*sinb*sxb,     -cosb*pyb*syb + hyb - pxb*sinb*syb,                 0,    0,
        0,                                      0,                                                  0,    1
    };
    return ret;
}

Mat4f Mat4f::maskspaceToMaskspace(Vec2f positionA, Vec2f hotspotA, Vec2f scaleA, float angleA, Vec2f positionB, Vec2f hotspotB, Vec2f scaleB, float angleB)
{
    float radiansA = -angleA * 0.0174532925f;
    float cosa = cosf(radiansA);
    float sina = sinf(radiansA);
    float sxa = scaleA.x;
    float sya = scaleA.y;
    float pxa = positionA.x;
    float pya = positionA.y;
    float hxa = hotspotA.x;
    float hya = hotspotA.y;
    
    float radiansB = angleB * 0.0174532925f;
    float cosb = cosf(radiansB);
    float sinb = sinf(radiansB);
    float sxb = 1.0f/scaleB.x;
    float syb = 1.0f/scaleB.y;
    float pxb = positionB.x;
    float pyb = positionB.y;
    float hxb = hotspotB.x;
    float hyb = hotspotB.y;
    
    Mat4f ret = {
        cosa*cosb*sxa*sxb - sina*sinb*sxa*sxb,
        cosa*sinb*sxa*syb + cosb*sina*sxa*syb,
        0,0,
        
        -cosa*sinb*sxb*sya - cosb*sina*sxb*sya,
        cosa*cosb*sya*syb - sina*sinb*sya*syb,
        0,0,
        
        cosa*(hya*sinb*sxb*sya - cosb*hxa*sxa*sxb) + cosb*(hya*sina*sya + pxa - pxb)*sxb + hxa*sina*sinb*sxa*sxb + hxb - (pya - pyb)*sinb*sxb,
        cosa*(-cosb*hya*sya*syb - hxa*sinb*sxa*syb) - cosb*(hxa*sina*sxa - pya + pyb)*syb + hya*sina*sinb*sya*syb + hyb + pxa*sinb*syb - pxb*sinb*syb,
        0,0,
        0,0,0,1
    };
    return ret;
}



Vec2f::Vec2f(){this->x = 0; this->y = 0;}
Vec2f::Vec2f(float x, float y){this->x = x; this->y = y;}

float Vec2f::distanceBetweenPositions(const Vec2f a, const Vec2f b)
{
	double dX = b.x - a.x;
	double dY = b.y - a.y;
	return sqrtf(dX*dX+dY*dY);
}

float Vec2f::distanceTo(const Vec2f point) const
{
	double dX = point.x - x;
	double dY = point.y - y;
	return sqrtf(dX*dX+dY*dY);
}

float Vec2f::distanceToSquared(const Vec2f point) const
{
	double dX = point.x - x;
	double dY = point.y - y;
	return dX*dX+dY*dY;
}

float Vec2f::angleTo(const Vec2f other) const
{
	return atan2f((float)(other.y-y), (float)(other.x-x));
}

bool Vec2f::isCCWtoLine(Vec2f a, Vec2f b) const
{
	return (b.x-a.x)*(y-a.y)-(b.y-a.y)*(x-a.x) <= 0;
}

bool Vec2f::isCCtoLine(Vec2f a, Vec2f b) const
{
	return (b.x-a.x)*(y-a.y)-(b.y-a.y)*(x-a.x) >= 0;
}

float Vec2f::triangleAreaToLine(Vec2f a, Vec2f b) const
{
	return (b.x-a.x)*(y-a.y)-(b.y-a.y)*(x-a.x);
}

void Vec2f::normalize()
{
	float len = sqrtf(x*x + y*y);
	if(len > 0)
	{
		float inv = 1.0f/len;
		x *= inv;
		y *= inv;
	}
	else
	{
		x = 0;
		y = 0;
	}
}

Vec2f Vec2f::normalized() const
{
	float len = sqrtf(x*x + y*y);
	if(len > 0)
	{
		Vec2f ret = Vec2f(x,y);
		float inv = 1.0f/len;
		ret.x *= inv;
		ret.y *= inv;
	}
	return Vec2fZero;
}

void Vec2f::normaliseFast()
{
	float len = Q_rsqrt(x*x + y*y);
	if(len > 0)
	{
		float inv = 1.0f/len;
		x *= inv;
		y *= inv;
	}
	else
	{
		x = 0;
		y = 0;
	}
}

Vec2f Vec2f::normalizedFast() const
{
	float len = Q_rsqrt(x*x + y*y);
	if(len > 0)
	{
		Vec2f ret = Vec2f(x,y);
		float inv = 1.0f/len;
		ret.x *= inv;
		ret.y *= inv;
	}
	return Vec2fZero;
}

Vec2f Vec2f::interpolate(const Vec2f a, const Vec2f b, double step)
{
	return Vec2f(a.x + (b.x-a.x)*step,
				 a.y + (b.y-a.y)*step);
}

Vec2f Vec2f::operator+(const Vec2f &rhs) const {return Vec2f(this->x + rhs.x, this->y + rhs.y);}
Vec2f Vec2f::operator-(const Vec2f &rhs) const {return Vec2f(this->x - rhs.x, this->y - rhs.y);}
Vec2f Vec2f::operator+(const float &rhs) const {return Vec2f(this->x + rhs, this->y + rhs);}
Vec2f Vec2f::operator-(const float &rhs) const {return Vec2f(this->x - rhs, this->y - rhs);}
Vec2f Vec2f::operator*(const float rhs) const {return Vec2f(this->x * rhs, this->y * rhs);}
Vec2f Vec2f::operator/(const float rhs) const {return Vec2f(this->x / rhs, this->y / rhs);}
Vec2f Vec2f::operator/(const Vec2f &rhs) const {return Vec2f(this->x / rhs.x, this->y / rhs.y);}
bool Vec2f::operator==(const Vec2f &rhs) const{return this->x == rhs.x && this->y == rhs.y;}
bool Vec2f::operator!=(const Vec2f &rhs) const{return this->x != rhs.x || this->y != rhs.y;}





Vec2i::Vec2i(){this->x = 0; this->y = 0;}
Vec2i::Vec2i(int x, int y){this->x = x; this->y = y;}
Vec2i::Vec2i(float x, float y){this->x = (int)x; this->y = (int)y;}
Vec2i::Vec2i(Vec2f fVec){this->x = (int)fVec.x; this->y = (int)fVec.y;}
Vec2i Vec2i::operator+(const Vec2i &rhs) const {return Vec2i(this->x + rhs.x, this->y + rhs.y);}
Vec2i Vec2i::operator-(const Vec2i &rhs) const {return Vec2i(this->x - rhs.x, this->y - rhs.y);}
Vec2i Vec2i::operator+(const float &rhs) const {return Vec2i(this->x + rhs, this->y + rhs);}
Vec2i Vec2i::operator-(const float &rhs) const {return Vec2i(this->x - rhs, this->y - rhs);}
Vec2i Vec2i::operator*(const float rhs) const {return Vec2i(this->x * rhs, this->y * rhs);}
Vec2i Vec2i::operator/(const float rhs) const {return Vec2i(this->x / rhs, this->y / rhs);}
Vec2i Vec2i::operator/(const Vec2i &rhs) const {return Vec2i(this->x / rhs.x, this->y / rhs.y);}
bool Vec2i::operator==(const Vec2i &rhs) const{return this->x == rhs.x && this->y == rhs.y;}
bool Vec2i::operator!=(const Vec2i &rhs) const{return this->x != rhs.x || this->y != rhs.y;}


ColorRGBA::ColorRGBA()
{
	r = g = b = a = 0;
}

ColorRGBA::ColorRGBA(float red, float green, float blue, float alpha)
{
	r = red;
	g = green;
	b = blue;
	a = alpha;
}

ColorRGBA::ColorRGBA(int color)
{
	r = (color & 0x000000FF)/255.0f;
	g = ((color & 0x0000FF00) >> 8)/255.0f;
	b = ((color & 0x00FF0000) >> 16)/255.0f;
	a = 1.0f;
}

ColorRGBA ColorRGBA::mix(ColorRGBA a, ColorRGBA b, float fraction)
{
	return ColorRGBA(a.r + (b.r-a.r)*fraction, a.g + (b.g-a.g)*fraction, a.b + (b.b-a.b)*fraction, a.a + (b.a-a.a)*fraction);
}


unsigned int ColorRGBA::getColorAsFormat(int format)
{
	switch(format)
	{
		default:
		case RGBA8888:
		case RGB888:
			return getRGBA8888();
		case RGBA4444:
			return getRGBA4444();
		case RGBA5551:
			return getRGBA5551();
		case RGB565:
			return getRGB565();
	}
}

unsigned int ColorRGBA::getRGBA8888()
{
	int ri = (int)(r*255)		& 0x000000FF;
	int gi = ((int)(g*255)*256 ) & 0x0000FF00;
	int bi = ((int)(b*255)*65536) & 0x00FF0000;
	int ai = ((int)(a*255)*16777216) & 0xFF000000;
	return ri | gi | bi | ai;
}

unsigned int ColorRGBA::getRGB888()
{
	int ri = (int)(r*255)		& 0x000000FF;
	int gi = ((int)(g*255)*256 ) & 0x0000FF00;
	int bi = ((int)(b*255)*65536) & 0x00FF0000;
	return ri | gi | bi;
}

unsigned short ColorRGBA::getRGBA4444()
{
	unsigned int rB = (unsigned int)((r*15)+0.49999);
	unsigned int gB = (unsigned int)((g*15)+0.49999);
	unsigned int bB = (unsigned int)((b*15)+0.49999);
	return (rB<<12|gB*256|bB<<4);
}

unsigned short ColorRGBA::getRGBA5551()
{
	unsigned short rB = (unsigned int)((r*31)+0.49999);
	unsigned short gB = (unsigned int)((g*31)+0.49999);
	unsigned short bB = (unsigned int)((b*31)+0.49999);
	return (rB<<11|gB<<6|bB<<1);
}

unsigned short ColorRGBA::getRGB565()
{
	unsigned short rB = (unsigned int)((r*31)+0.49999);
	unsigned short gB = (unsigned int)((g*63)+0.49999);
	unsigned short bB = (unsigned int)((b*31)+0.49999);
	return (rB<<11|gB<<5|bB);
}

void ColorRGBA::premultiply()
{
	r *= a;
	g *= a;
	b *= a;
}

void ColorRGBA::unpremultiply()
{
	float inv = 1/a;
	r *= inv;
	g *= inv;
	b *= inv;
}


GradientColor::GradientColor()
{
	a = ColorRGBA();
	b = ColorRGBA();
	c = ColorRGBA();
	d = ColorRGBA();
}

GradientColor::GradientColor(ColorRGBA a, ColorRGBA b, ColorRGBA c, ColorRGBA d)
{
	this->a = a;
	this->b = b;
	this->c = c;
	this->d = d;
}

GradientColor::GradientColor(int color)
{
	a = b = c = d = ColorRGBA(color);
}

GradientColor::GradientColor(ColorRGBA color)
{
	a = b = c = d = color;
}

GradientColor::GradientColor(ColorRGBA a, ColorRGBA b, BOOL horizontal)
{
	if(horizontal)
	{
		this->a = this->c = a;
		this->b = this->d = b;
	}
	else
	{
		this->a = this->b = a;
		this->c = this->d = b;
	}
}

GradientColor::GradientColor(int a, int b, int c, int d)
{
	this->a = ColorRGBA(a);
	this->b = ColorRGBA(b);
	this->c = ColorRGBA(c);
	this->d = ColorRGBA(d);
}

ColorRGBA GradientColor::getColorAtFraction(float x, float y)
{
	ColorRGBA hozA = ColorRGBA::mix(a, b, x);
	ColorRGBA hozB = ColorRGBA::mix(c, d, x);
	return ColorRGBA::mix(hozA, hozB, y);
}

GradientColor::GradientColor(int a, int b, BOOL horizontal)
{
	if(horizontal)
	{
		this->a = this->c = ColorRGBA(a);
		this->b = this->d = ColorRGBA(b);
	}
	else
	{
		this->a = this->b = ColorRGBA(a);
		this->c = this->d = ColorRGBA(b);
	}
}

