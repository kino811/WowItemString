using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using MoonSharp.Interpreter;
using System;

[MoonSharpUserDataAttribute]
public class MyUserData {
    public void Do() {
        Debug.Log("MyUserData.Do()");
    }
}

public class TestLua : MonoBehaviour {

	// Use this for initialization
	void Start () {
	    DoTest();
	}
	
    void DoTest() {
        string scriptCode = @"
            local messageString = [=[|cff969696|Hitem:{'id':170000,'needLv':6,'soulcoreMaxLv':0,'bindInfo':{'unbindableCount':100,'bindType':0},'duration':{'maxDuration':100,'duration':100},'strengtheningStep':0,'quality':0,'properties':[{'id':0,'value':0},{'id':1,'value':0},{'id':2,'value':0},{'id':3,'value':0},{'id':4,'value':0},{'id':5,'value':0},{'id':6,'value':0},{'id':7,'value':0},{'id':8,'value':0},{'id':9,'value':0}]}[Legend Sword]|h|r]=]

            return table.tostring({GetInfosFromHyperLinkFormat(messageString)})
        ";

        UserData.RegisterAssembly();

        Script script = new Script();
        script.DebuggerEnabled = true;
        script.DoFile("messageFormat");
        script.DoFile("util");

        script.Globals["myUserData"] = new MyUserData();

        DynValue ret = script.DoString(scriptCode);

        Debug.LogFormat("ret : {0}", ret.String);
    }
}
