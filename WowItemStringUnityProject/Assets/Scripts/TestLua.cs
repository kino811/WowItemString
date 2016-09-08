using UnityEngine;
using System.Collections;
using MoonSharp.Interpreter;

public class TestLua : MonoBehaviour {

	// Use this for initialization
	void Start () {
	    DoTest();
	}
	
    void DoTest() {
        string luaString = @"
            -- defines a factorial function
            function Fact(n)
                if (n == 0) then
                    return 1
                else
                    return n * Fact(n - 1)
                end
            end

            return Fact(5)
        ";

        DynValue res = Script.RunString(luaString);

        Debug.Log("lua-string evaluation result: " + res.Number);
    }
}
