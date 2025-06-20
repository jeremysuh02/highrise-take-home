/*

    Copyright (c) 2025 Pocketz World. All rights reserved.

    This is a generated file, do not edit!

    Generated by com.pz.studio
*/

#if UNITY_EDITOR

using System;
using System.Linq;
using UnityEngine;
using Highrise.Client;
using Highrise.Studio;
using Highrise.Lua;
using UnityEditor;

namespace Highrise.Lua.Generated
{
    [AddComponentMenu("Lua/storebuttonui")]
    [LuaRegisterType(0xf1a56d871b6fa578, typeof(LuaBehaviour))]
    public class storebuttonui : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "dc991eb5859fc934484141ee7cad0eb0";
        public override string ScriptGUID => s_scriptGUID;

        [SerializeField] public UnityEngine.GameObject m_UpgradeUI = default;

        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), null),
                CreateSerializedProperty(_script.GetPropertyAt(1), null),
                CreateSerializedProperty(_script.GetPropertyAt(2), m_UpgradeUI),
            };
        }
        
#if HR_STUDIO
        [MenuItem("CONTEXT/storebuttonui/Edit Script")]
        private static void EditScript()
        {
            VisualStudioCodeOpener.OpenPath(AssetDatabase.GUIDToAssetPath(s_scriptGUID));
        }
#endif
    }
}

#endif
