import re
import sys

def convert_yaml_to_lua(input_file, output_file):
    try:
        with open(input_file, 'r') as f:
            content = f.read()

        # Split by the yaml entry separator
        entries = content.split('- id:')
        
        lua_map = "local models_map = {\n"
        count = 0

        for entry in entries:
            # Extract fields using regex
            mfr_match = re.search(r'manufacturer:\s*["\']?([^"\n\r\']+)["\']?', entry)
            model_match = re.search(r'model:\s*["\']?([^"\n\r\']+)["\']?', entry)
            profile_match = re.search(r'deviceProfileName:\s*["\']?([^"\n\r\']+)["\']?', entry)

            if mfr_match and model_match and profile_match:
                mfr = mfr_match.group(1).strip()
                model = model_match.group(1).strip()
                profile = profile_match.group(1).strip()
                
                # Format: ["Mfr/Model"] = "profile",
                line = f'  ["{mfr}/{model}"] = "{profile}",\n'
                lua_map += line
                count += 1

        lua_map += "}\nreturn models_map"

        with open(output_file, 'w') as f:
            f.write(lua_map)
        
        print(f"Success! Processed {count} devices into {output_file}")

    except FileNotFoundError:
        print(f"Error: The file '{input_file}' was not found.")

if __name__ == "__main__":
    # Check if arguments were passed, otherwise use defaults
    in_file = sys.argv[1] if len(sys.argv) > 1 else 'fingerprints.yml'
    out_file = sys.argv[2] if len(sys.argv) > 2 else 'models_map.lua'
    
    convert_yaml_to_lua(in_file, out_file)