// Requires SWIG 3!

%module arrayfire
%include "typemaps.i"
%include "numpy.i"
// For typemaps for std::exception
%include "exception.i"
%include "std_complex.i"

#undef __cplusplus
#define __cplusplus 199711L

 // Ignore attributes to prevent compilation errors
#define __attribute__(x) 

 %{
 /* Includes the header in the wrapper code */
#include "af/algorithm.h"
#include "af/arith.h"
#include "af/array.h"
#include "af/blas.h"
#include "af/constants.h"
#include "af/complex.h"
#include "af/data.h"
#include "af/defines.h"
#include "af/device.h"
#include "af/exception.h"
#include "af/features.h"
#include "af/gfor.h"
#include "af/graphics.h"
#include "af/image.h"
#include "af/index.h"
#include "af/lapack.h"
#include "af/seq.h"
#include "af/signal.h"
#include "af/statistics.h"
#include "af/timing.h"
#include "af/util.h"
#include "af/version.h"
#include "af/vision.h"
 %}

%rename(astype) af::array::array_proxy::as(dtype type) const;
// as is a python keyword
%rename(astype) af::array::as(dtype type) const;
%rename(__getitem__) af::array::operator();

// For some reason I couldn't make this work properly when it was
// overloaded with other stuff
%rename(array_from_handle) af::array::array(const af_array handle);
   
%typemap(in) void * {
  $1 = (void *)PyInt_AsLong($input);
}


%typemap(in, numinputs=0) af_array *OUTPUT (af_array temp) { 
  $1 = &temp;
 }


%typemap(argout) af_array * OUTPUT {
    PyObject *o, *o2, *o3;
    o =  PyInt_FromLong((long)*$1);
    if ((!$result) || ($result == Py_None)) {
        $result = o;
    } else {
        if (!PyTuple_Check($result)) {
            PyObject *o2 = $result;
            $result = PyTuple_New(1);
            PyTuple_SetItem($result,0,o2);
        }
        o3 = PyTuple_New(1);
        PyTuple_SetItem(o3,0,o);
        o2 = $result;
        $result = PySequence_Concat(o2,o3);
        Py_DECREF(o2);
        Py_DECREF(o3);
    }
}


%typemap(out) af::array::array_proxy {
  // This looks really strange but it's necessary due to the overloading of & and *
  $result = SWIG_NewPointerObj(new af::array((af::array)(*(&$1))), SWIGTYPE_p_af__array, SWIG_POINTER_OWN |  0 );
}

%typemap(in) dim_t *  {
  $1 = (dim_t *)PyInt_AsLong($input);
}

/* %typemap(in) const dim_t *  { */
/*   $1 = (const dim_t *)PyInt_AsLong($input); */
/* } */

/* %typemap(in)  const dim_t * const  { */
/*   $1(( dim_t *)PyInt_AsLong($input)); */
/* } */

%apply af_array * OUTPUT { af_array *arr };
%apply af_array * OUTPUT { af_array *out };
%feature("flatnested") af::array::array_proxy;

%ignore af::operator+(const dim4& first, const dim4& second);
%ignore af::operator-(const dim4& first, const dim4& second);
%ignore af::operator*(const dim4& first, const dim4& second);
%ignore operator<<(std::ostream &s, const exception &e);
%define IGNORE(func)
%ignore func(dim_type const,dim_type const);
%ignore func(dim_type const,dim_type const,dim_type const);
%ignore func(dim_type const,dim_type const,dim_type const,dim_type const);
%ignore func(dim_type,dim_type);
%ignore func(dim_type,dim_type,dim_type);
%ignore func(dim_type,dim_type,dim_type,dim_type);
%enddef
IGNORE(af::randu)
IGNORE(af::randn)
IGNORE(af::identity)
IGNORE(af::array::array)

%define TYPE_IGNORE(func, type)
%ignore af::func(type, dim_type const,dim_type const);
%ignore af::func(type, dim_type const,dim_type const,dim_type const);
%ignore af::func(type, dim_type const,dim_type const,dim_type const,dim_type const);
%enddef
TYPE_IGNORE(constant, float)
TYPE_IGNORE(constant, double)
TYPE_IGNORE(constant, int)
TYPE_IGNORE(constant, unsigned int)
TYPE_IGNORE(constant, long)
TYPE_IGNORE(constant, unsigned long)
TYPE_IGNORE(constant, long long)
TYPE_IGNORE(constant, unsigned long long)
TYPE_IGNORE(constant, char)
TYPE_IGNORE(constant, unsigned char)
TYPE_IGNORE(constant, bool)
TYPE_IGNORE(constant, cdouble)
TYPE_IGNORE(constant, cfloat)

%ignore af::array::array_proxy::unlock() const;
%ignore af::array::unlock() const;
%ignore af::array::array_proxy::lock() const;
%ignore af::array::lock() const;

// Seems to be missing
%ignore af::dog(af::array const&, int, int);
%ignore af::dog;
%ignore af::unwrap;
%ignore af_dog;
%ignore af_unwrap;
//%ignore af::unwrap(af::array const&, long long, long long, long long, long long, long long, long long)

// These ones are missing compatible.h in the header
%ignore af::setintersect(const array &first, const array &second, const bool is_unique=false);
%ignore af::setunion(const array &first, const array &second, const bool is_unique=false);
%ignore af::setunique(const array &in, const bool is_sorted=false);

// These ones have on implementation that I could find
%ignore af::operator+(const af::cfloat &lhs, const double &rhs);
%ignore af::operator+(const af::cdouble &lhs, const double &rhs);

// Something wrong with these ones also
%ignore af::array::array_proxy::col(int) const;
%ignore af::array::array_proxy::cols(int, int) const;
%ignore af::array::array_proxy::row(int) const;
%ignore af::array::array_proxy::rows(int, int) const;
%ignore af::array::array_proxy::slice(int) const;
%ignore af::array::array_proxy::slices(int, int) const;



%ignore operator+(double, seq);
%ignore operator-(double, seq);
%ignore operator*(double, seq);

// For some reason gcc-4.8.5 doesn't like these operator
//%rename(proxy_asarray) af::array::array_proxy::operator array();
%ignore af::array::array_proxy::operator array();
//%rename(as_const_array) af::array::array_proxy::operator array() const;
%ignore af::array::array_proxy::operator array() const;

%rename(seq_asarray) af::seq::operator array() const;
%rename(g_afDevice) ::afDevice;
%rename(g_afHost) ::afHost;

%rename(logical_or) af::operator||;
%rename(logical_and) af::operator&&;
%rename(copy_on_write) af::array::operator=;
%rename(copy_on_write) af::array::array_proxy::operator=;

%rename(logical_not) af::array::operator!;
%rename(__getitem__) af::dim4::operator[];
%rename(copy) af::seq::operator=;
%rename(pprint) af::print;
%rename(copy) af::features::operator=;

%rename(copy) af::features::operator=;

%rename(__add_float__) af::operator+(const array&, const float &);
%rename(__radd_float__) af::operator+(const float &, const array&);
%rename(__sub_float__) af::operator-(const array&, const float &);
%rename(__rsub_float__) af::operator-(const float &, const array&);
%rename(__mul_float__) af::operator*(const array&, const float &);
%rename(__rmul_float__) af::operator*(const float &, const array&);
%rename(__div_float__) af::operator/(const array&, const float &);
%rename(__rdiv_float__) af::operator/(const float &, const array&);

// Try to handle exceptions
%exception {
try {
  $function
    }
catch (const std::exception & e) {
  PyErr_SetString(PyExc_RuntimeError, e.what());
  return NULL;
}
}

%typemap(out) af::af_cfloat {
  $result = PyComplex_FromDoubles(af::real($1),af::imag($1));
 }

%typemap(out) af::af_cdouble  {
  $result = PyComplex_FromDoubles(af::real($1),af::imag($1));
 }


// Convert certain pointer to a python long so we can observe its value
// in particular in the case of the return value of array::device<T>.
// The choice of float is arbitrary.
%typemap(out) float * {
  $result = PyInt_FromLong((uint64_t)$1);
 }

%include "af/defines.h"
%include "af/index.h"
%include "af/complex.h"
%include "af/algorithm.h"
%include "af/arith.h"
%include "af/array.h"
%include "af/blas.h"
%include "af/constants.h"
%include "af/data.h"
%include "af/device.h"
%include "af/exception.h"
%include "af/features.h"
%include "af/gfor.h"
%include "af/graphics.h"
%include "af/image.h"
%include "af/lapack.h"
%include "af/seq.h"
%include "af/signal.h"
%include "af/statistics.h"
%include "af/timing.h"
%include "af/util.h"
%include "af/version.h"
%include "af/vision.h"

%extend af::array {

  void setValue(const af::index &s0, const af::index &s1,
		const af::array &value){
    af_array lhs = self->get();
    af_array rhs = value.get();
    af_index_t indices[] = {s0.get(), s1.get()};
    af_err err = af_assign_gen(&lhs, lhs, 2, indices, rhs);
    if (err != AF_SUCCESS){
      throw af::exception("Failed to copy", __FILE__, __LINE__  - 1, err);
    }    
  }
  void setValue(const af::index &s0, const af::index &s1,
		const af::index &s2, const af::array &value){
    af_array lhs = self->get();
    af_array rhs = value.get();
    af_index_t indices[] = {s0.get(), s1.get(), s2.get()};
    af_err err = af_assign_gen(&lhs, lhs, 3, indices, rhs);
    if (err != AF_SUCCESS){
      throw af::exception("Failed to copy", __FILE__, __LINE__  - 1, err);
    }    
  }
  void setValue(const af::index &s0, const af::index &s1,
		const af::index &s2, const af::index &s3,
		const af::array &value){
    af_array lhs = self->get();
    af_array rhs = value.get();
    af_index_t indices[] = {s0.get(), s1.get(), s2.get(), s3.get()};
    af_err err = af_assign_gen(&lhs, lhs, 4, indices, rhs);
    if (err != AF_SUCCESS){
      throw af::exception("Failed to copy", __FILE__, __LINE__  - 1, err);
    }    
  }
  void setValue(const af::index &s0, const af::array &value){
    af_array lhs = self->get();
    af_array rhs = value.get();
    af_index_t indices[] = {s0.get()};
    af_err err = af_assign_gen(&lhs, lhs, 1, indices, rhs);
    if (err != AF_SUCCESS){
      throw af::exception("Failed to copy", __FILE__, __LINE__  - 1, err);
    }    
  }
  void setValue(const af::index &s0, double value){
    af::array value_a = (*self)(s0);
    value_a = value;
    af_array lhs = self->get();
    af_array rhs = value_a.get();
    af_index_t indices[] = {s0.get()};
    af_err err = af_assign_gen(&lhs, lhs, 1, indices, rhs);
    if (err != AF_SUCCESS){
      throw af::exception("Failed to copy", __FILE__, __LINE__  - 1, err);
    }    
    //    ((*self)(s0)) = value;
  }
  void setValue(const af::index &s0, std::complex<double> value){
    af::array value_a = (*self)(s0);
    value_a = af::af_cdouble(value.real(),value.imag());
    af_array lhs = self->get();
    af_array rhs = value_a.get();
    af_index_t indices[] = {s0.get()};
    af_err err = af_assign_gen(&lhs, lhs, 1, indices, rhs);
    if (err != AF_SUCCESS){
      throw af::exception("Failed to copy", __FILE__, __LINE__  - 1, err);
    }
    
    //    ((*self)(s0)) = af::af_cdouble(value.real(),value.imag());
  }

  %template(device_f32) device<float>;
  %template(device_f64) device<double>;
  %template(device_s32) device<int32_t>;
  %template(device_u32) device<uint32_t>;
  // These templates were missing on Linux
  //  %template(device_s64) device<int64_t>;
  //  %template(device_u64) device<uint64_t>;
  %template(device_c32) device<af::cfloat>;
  %template(device_c64) device<af::cdouble>;

};

%extend af_index_t{
  af_array arr(){
    return self->idx.arr;
  }
  
  af_seq seq(){
    return self->idx.seq;
  }

  int arr_elements(){
    if(self->isSeq){
      return 0;
    }
    dim_t dims[4];
    af_get_dims(&dims[0], &dims[1], &dims[2], &dims[3], self->idx.arr);
    int ret = 1;
    unsigned numdims;
    af_get_numdims(&numdims, self->idx.arr);
    for(int i = 0;i<numdims;i++){
      ret *= dims[i];
    }
    return ret;
  }
};


%template(max_f32) af::max<float>;
%template(max_f64) af::max<double>;
%template(max_s32) af::max<int32_t>;
%template(max_u32) af::max<uint32_t>;
//%template(max_s64) af::max<int64_t>(const array &in);
//%template(max_u64) af::max<uint64_t>;
%template(max_c32) af::max<af::cfloat>;
%template(max_c64) af::max<af::cdouble>;


%template(min_f32) af::min<float>;
%template(min_f64) af::min<double>;
%template(min_s32) af::min<int32_t>;
%template(min_u32) af::min<uint32_t>;
//%template(min_s64) af::min<int64_t>(const array &in);
//%template(min_u64) af::min<uint64_t>;
%template(min_c32) af::min<af::cfloat>;
%template(min_c64) af::min<af::cdouble>;


