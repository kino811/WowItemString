using UnityEngine;
using System.Collections;
using MoonSharp.Interpreter;

public class TestLua : MonoBehaviour {

	// Use this for initialization
	void Start () {
	    DoTest();
	}
	
    void DoTest() {
        // test lua-string run
        {
            string luaString = @"return 'hello lua'";
            DynValue res = Script.RunString(luaString);
            Debug.Log("lua-string result: " + res.String);
        }

        // test lua run by script-object
        {
            string scriptCode = @"
                -- defines a factorial function
                function Fact(n)
                    if (n == 0) then
                        return 1
                    else
                        return n * Fact(n - 1)
                    end
                end

                return Fact(mynumber)";

            Script script = new Script();

            // access the global environment
            script.Globals["mynumber"] = 7;

            DynValue res = script.DoString(scriptCode);
            Debug.Log("lua-code result: " + res.Number);
        }
    }
}
