using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using MoonSharp.Interpreter;

public class LuaScriptLoader : MonoBehaviour {
    void Awake() {
        Dictionary<string, string> scripts = new Dictionary<string, string>();
        Object[] result = Resources.LoadAll("MoonSharp/Scripts");

        foreach (TextAsset ta in result.OfType<TextAsset>()) {
            scripts.Add(ta.name, ta.text);
            //Debug.LogFormat("add script. {0}, {1}", ta.name, ta.text);
        }

        Script.DefaultOptions.ScriptLoader = new MoonSharp.Interpreter.Loaders.UnityAssetsScriptLoader(scripts);
    }
}
