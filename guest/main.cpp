// omnigen2.elf -- the OmniGen2 and EditScore surface.
//
// Every ADD_API_FUNCTION here is reachable from GDScript as Sandbox.vmcall(name, ...). The body is
// Lean (Omnigen2/Guest.lean) compiled for riscv64 and linked into this guest. The Lean exports take
// and return a Lean String, and this shim converts them to and from Godot's own String.
//
//   omnigen2_version() -> String    the version of this surface
//   omnigen2_ask(request) -> String the answer to one request, as JSON, or the refusal by name
//
// main() registers the surface and halts: a main that returns runs glibc's destructors and leaves
// the machine unusable for later calls.
//
// SPDX-License-Identifier: MIT

#include <api.hpp>

#include <lean/lean.h>

#include <cstdint>
#include <string>

extern "C" {
lean_object *initialize_omnigen2_Omnigen2_Guest(uint8_t builtin);
lean_object *omnigen2_ask_json(lean_object *request);
lean_object *omnigen2_version_text(lean_object *request);
}

static bool g_initialised = false;

static void omnigen2_init()
{
	if (g_initialised)
		return;
	g_initialised = true;
	lean_object *res = initialize_omnigen2_Omnigen2_Guest(1 /* builtin */);
	lean_io_mark_end_initialization();
	if (lean_io_result_is_ok(res)) {
		lean_dec_ref(res);
		lean_init_task_manager();
	} else {
		lean_io_result_show_error(res);
		lean_dec_ref(res);
	}
}

static Variant answer(lean_object *(*entry)(lean_object *), const String &request)
{
	omnigen2_init();
	const std::string in = request;
	lean_object *value = entry(lean_mk_string_from_bytes(in.data(), in.size()));
	const std::string out(lean_string_cstr(value), lean_string_size(value));
	lean_dec_ref(value);
	return Variant(String(out));
}

static Variant omnigen2_version()
{
	return answer(omnigen2_version_text, String(""));
}

static Variant omnigen2_ask(String request)
{
	return answer(omnigen2_ask_json, request);
}

int main()
{
	ADD_API_FUNCTION(omnigen2_version, "String", "", "The version of this guest's surface.");
	ADD_API_FUNCTION(omnigen2_ask, "String", "String request",
		"The answer to one request, as JSON, or the refusal by name. Known requests: mul_mat and mul_mat flip.");
	halt();
}
