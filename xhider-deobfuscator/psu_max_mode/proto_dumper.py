import sys
import json
import struct

def decode_psu_lzw(encoded_str):
    if encoded_str.startswith("PSU|"):
        encoded_str = encoded_str[4:]
    d = {i: chr(i) for i in range(258)}
    next_index = 258
    pos = 0
    def get_next_val():
        nonlocal pos
        if pos >= len(encoded_str): return None
        o_str = encoded_str[pos:pos+1]
        pos += 1
        o = int(o_str, 36)
        val_str = encoded_str[pos:pos+o]
        pos += o
        return int(val_str, 36)

    first_val = get_next_val()
    if first_val is None: return b""
    output = []
    o = d[first_val]
    output.append(o)
    while True:
        n = get_next_val()
        if n is None: break
        if n in d: t = d[n]
        else: t = o + o[0]
        output.append(t)
        d[next_index] = o + t[0]
        next_index += 1
        o = t
    return "".join(output).encode('latin-1')

class PSUParsers:
    def __init__(self, data):
        self.data = data
        self.pos = 0
        self.xor_key = 102
        self.nodes = {}
        self.node_counter = 0

    def read_byte(self):
        b = self.data[self.pos]
        val = (b ^ self.xor_key) & 0xFF
        self.xor_key = val
        self.pos += 1
        return val

    def read_int2(self):
        b1 = self.read_byte()
        b2 = self.read_byte()
        return (b2 << 8) | b1

    def read_int4(self):
        b1 = self.read_byte()
        b2 = self.read_byte()
        b3 = self.read_byte()
        b4 = self.read_byte()
        return (b4 << 24) | (b3 << 16) | (b2 << 8) | b1

    def read_double(self):
        low = self.read_int4()
        high = self.read_int4()
        # IEEE 754 double
        combined = (high << 32) | (low & 0xFFFFFFFF)
        return struct.unpack('>d', struct.pack('>Q', combined))[0]

    def read_string(self):
        length = self.read_int4()
        if length == 0: return ""
        res = []
        for _ in range(length):
            res.append(chr(self.read_byte()))
        return "".join(res)

    def register_node(self, node):
        node_id = str(self.node_counter)
        self.node_counter += 1
        self.nodes[node_id] = node
        return node_id

    def parse_proto(self, instr_key, const_key, sub_key, param_key, unknown_key, op_key, next_key, a_key, b_key, c_key, unk_key2):
        num_subprotos = self.read_int4()
        sys.stderr.write(f"num_subprotos: {num_subprotos}\n")
        if num_subprotos > 1000: # sanity check
            sys.stderr.write(f"Warning: Huge num_subprotos at pos {self.pos}\n")
            return "ERROR"
        subprotos = {}
        for i in range(num_subprotos):
            subprotos[str(i)] = {"$ref": self.parse_proto(instr_key, const_key, sub_key, param_key, unknown_key, op_key, next_key, a_key, b_key, c_key, unk_key2)}
        
        params_count = self.read_byte()
        unknown = self.read_int2()
        
        num_constants = self.read_int4()
        constants = {}
        for i in range(num_constants):
            type_byte = self.read_byte()
            if type_byte == 37: # bool
                constants[str(i)] = (self.read_byte() != 0)
            elif type_byte == 6: # number
                constants[str(i)] = self.read_double()
            elif type_byte == 1: # string
                constants[str(i)] = self.read_string()
            else:
                constants[str(i)] = None

        num_instructions = self.read_int4()
        instructions = {}
        for i in range(num_instructions):
            instructions[str(i)] = {}
        
        # Link instructions
        for i in range(num_instructions):
            val = self.read_byte()
            if val != 0:
                val -= 1
                op_type = val & 0x7 # r(n, 1, 3)
                # Field roles might vary, but let's follow the chunk_1 logic
                # h, i, a, c, s, _
                # if u==5: _=d, a=e, i=l, c=d, h=table
                # if u==1: _=d, a=e, i=l
                # if u==0: _=d, a=d, i=l, c=d
                # if u==3: _=d, a=f[e], i=l, c=d
                # if u==2: _=d, a=f[e], i=l
                
                # We'll use names from print_hi.chunk_1.beautified.lua
                # h = -528061, i = "Ez0w", a = -199155, c = "t6XnFVycJs", s = "Ez0w", _ = "o5nR3uTSJ"
                
                # Wait, the Lua script assigns:
                # n["t6XnFVycJs"]=c;
                # n["Ez0w"]=s;
                # n[-528061]=i;
                # n[-199155]=a;
                # n[-758783]=h;
                # n['o5nR3uTSJ']=_;
                
                field_op = -528061
                field_next = "Ez0w"
                field_A = "o5nR3uTSJ"
                field_B = -199155
                field_C = "t6XnFVycJs"
                
                instr = instructions[str(i)]
                
                _v, a_v, i_v, c_v, s_v, h_v = 0, 0, 0, 0, 0, 0
                
                if op_type == 5:
                    _v = self.read_int2()
                    a_v = self.read_int4()
                    i_v = self.read_byte()
                    c_v = self.read_int2()
                    # h_v is a table... skip for now?
                elif op_type == 1:
                    _v = self.read_int2()
                    a_v = self.read_int4()
                    i_v = self.read_byte()
                elif op_type == 0:
                    _v = self.read_int2()
                    a_v = self.read_int2()
                    i_v = self.read_byte()
                    c_v = self.read_int2()
                elif op_type == 3:
                    _v = self.read_int2()
                    target_idx = self.read_int4()
                    a_v = {"$ref": str(target_idx)}
                    i_v = self.read_byte()
                    c_v = self.read_int2()
                elif op_type == 2:
                    _v = self.read_int2()
                    target_idx = self.read_int4()
                    a_v = {"$ref": str(target_idx)}
                    i_v = self.read_byte()
                
                # Assign based on bitflags in n
                # if r(n, 5, 5) == 1: a = constants[a]
                # if r(n, 4, 4) == 1: _ = constants[_]
                # if r(n, 6, 6) == 1: c = constants[c]
                
                if (val >> 4) & 1: a_v = constants.get(str(a_v), a_v) if not isinstance(a_v, dict) else a_v
                if (val >> 3) & 1: _v = constants.get(str(_v), _v)
                if (val >> 5) & 1: c_v = constants.get(str(c_v), c_v)
                
                # Next instruction logic
                if (val >> 7) & 1: s_v = sub_key # wait, s is field_next
                else: s_v = str(i + 1)
                
                instr[op_key] = i_v
                instr[next_key] = {"$ref": s_v} if s_v in instructions else s_v
                instr[a_key] = _v
                instr[b_key] = a_v
                instr[c_key] = c_v

        proto = {
            instr_key: instructions,
            const_key: constants,
            sub_key: subprotos,
            param_key: params_count,
            unknown_key: unknown
        }
        return self.register_node(proto)

if __name__ == "__main__":
    with open(sys.argv[1], "r", encoding="utf-8") as f:
        content = f.read()
    
    import re
    match = re.search(r'["\']PSU\|([^"\']+)["\']', content)
    if not match:
        print("PSU string not found")
        sys.exit(1)
    
    binary_data = decode_psu_lzw("PSU|" + match.group(1))
    
    # Keys from print_hi.chunk_1.beautified.lua
    instr_key = "117478"
    const_key = "IziP"
    sub_key = "eWkhhHi"
    param_key = "-777060"
    unknown_key = "394758"
    
    op_key = "-528061"
    next_key = "Ez0w"
    a_key = "o5nR3uTSJ"
    b_key = "-199155"
    c_key = "t6XnFVycJs"
    unk_key2 = "-758783"

    parser = PSUParsers(binary_data)
    root_id = parser.parse_proto(instr_key, const_key, sub_key, param_key, unknown_key, op_key, next_key, a_key, b_key, c_key, unk_key2)
    
    output = {
        "root": root_id,
        "nodes": parser.nodes
    }
    print(json.dumps(output, indent=2))
