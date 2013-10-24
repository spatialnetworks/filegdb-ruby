
#include "field_info.hpp"

namespace filegdb {

VALUE field_info::_klass = Qnil;

VALUE field_info::klass() {
  return field_info::_klass;
}

field_info::~field_info() {
  if (_fieldInfo) {
    delete _fieldInfo;
    _fieldInfo = NULL;
  }
}

VALUE field_info::get_field_count(VALUE self) {
  filegdb::field_info *info = unwrap(self);

  int fieldCount = -1;

  fgdbError hr = info->value().GetFieldCount(fieldCount);

  if (FGDB_IS_FAILURE(hr)) {
    FGDB_RAISE_ERROR(hr);
    return Qnil;
  }

  return INT2FIX(fieldCount);
}

VALUE field_info::get_field_name(VALUE self, VALUE fieldIndex) {
  CHECK_ARGUMENT_FIXNUM(fieldIndex);

  filegdb::field_info *info = unwrap(self);

  std::wstring fieldName;

  fgdbError hr = info->value().GetFieldName(FIX2INT(fieldIndex), fieldName);

  if (FGDB_IS_FAILURE(hr)) {
    FGDB_RAISE_ERROR(hr);
    return Qnil;
  }

  return rb_str_new2(to_char_array(fieldName));
}

void field_info::define(VALUE module)
{
  field_info::_klass = rb_define_class_under(module, "FieldInfo", rb_cObject);
  base::define(field_info::_klass, false);
  rb_define_method(field_info::_klass, "get_field_count", FGDB_METHOD(field_info::get_field_count), 0);
  rb_define_method(field_info::_klass, "get_field_name", FGDB_METHOD(field_info::get_field_name), 1);
}

}



