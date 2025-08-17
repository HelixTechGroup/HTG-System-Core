Scriptname HTG:Collections:List extends ObjectReference
import HTG
import HTG:SystemLogger
import HTG:IntUtility
import HTG:UtilityExt
import HTG:FormUtility
import HTG:Structs

String Property ArrayType = "Var" Auto Hidden

Int Property Count Hidden
    Int Function Get()
        return _count
    EndFunction
EndProperty

Var[] Property _Array Hidden
    Var[] Function Get()
        return _internalArray
    EndFunction
EndProperty

Bool Property IsInitialized Hidden
    Bool Function Get()
        return _isInitialized
    EndFunction
EndProperty

Guard _arrayGuard ProtectsFunctionLogic
Var[] _internalArray
Bool _isInitialized
Int _count = 0
Int _trackedIndex = 0
Int _maxSize = 128 Const

List Function List(SystemModuleInformation akMod, Int aiSize = 0) Global 
    List res = _CreateList(akMod, aiSize = aiSize)
    If !HTG:UtilityExt.IsNone(res)
        LogObjectGlobal(res, "HTG:Collections:List.List(" + aiSize  + "): " + res)
    EndIf

    return res
EndFunction

; List Function ListIntegrated(SystemModuleInformation akMod, Int aiSize = 0) Global 
;     If HTG:UtilityExt.IsNone(akMod)
;         return None
;     EndIf

;     If !akMod.IsCoreIntegrated
;         return List(aiSize)
;     EndIf

;     List res
;     res = _CreatedRegisteredList(akMod, res, aiSize)
;     LogObjectGlobal(res, "HTG:Collections:List.List(" + aiSize  + "): " + res)
;     return res
; EndFunction

Bool Function Initialize(Int aiSize = 0)
    If _isInitialized
        return False
    EndIf

    TryLockGuard _arrayGuard
        _internalArray = new Var[aiSize]
        _trackedIndex = 0
        _count = 0
        _isInitialized = True
    EndTryLockGuard

    return True
EndFunction

Function Clear()
    If !_isInitialized
        return
    EndIf

    TryLockGuard _arrayGuard
        _internalArray.Clear()
        _count = 0
        _trackedIndex = 0
        ; _isInitialized = False
    EndTryLockGuard
EndFunction

Var Function GetVarAt(Int index)
    If index < Count
        return _internalArray[index]
    EndIf
    
    return None
EndFunction

Int Function Add(Var akItem)
    If !_isInitialized || !TestType(akItem)
        return -1
    EndIf

    ; If _internalArray == None || !_isInitialized
    ;     Initialize()
    ; EndIf

    Int fI = Find(akItem)
    If fI > -1
        return fI; Update(akItem)
    EndIf


    Int i = -1
    TryLockGuard _arrayGuard
        i = _trackedIndex ; FindFirstEmpty()
        Int kCount = _internalArray.Length
        If _trackedIndex >= 0 && _trackedIndex < kCount
            _internalArray[_trackedIndex] = akItem
            _trackedIndex += 1
            _count += 1
        Else
            If _internalArray.Length < _maxSize
                _internalArray.Add(akItem)
                _trackedIndex += 1
                _count += 1
                i = _internalArray.Length - 1
            EndIf
        EndIf
    EndTryLockGuard

    ; Clean()
    LogObjectGlobal(akItem as ScriptObject, "Added item with Index: " + i + " and Count: " + _count)
    return i
EndFunction

Int Function AddList(List akList)
    If !_isInitialized
        return -1
    EndIf

    Int i = -1
    Int kI = 0
    While kI < akList.Count
        Var kItem = akList.GetVarAt(kI)
        If TestType(kItem) 
            Int fI = Find(kItem)
            If fI < 0
                TryLockGuard _arrayGuard
                    i = _trackedIndex ; FindFirstEmpty()
                    If i > -1 && _trackedIndex <= _internalArray.Length
                        _internalArray[i] = kItem
                        _trackedIndex += 1
                        _count += 1
                    Else
                        If _internalArray.Length < _maxSize
                            _internalArray.Add(kItem, 1)
                            _trackedIndex += 1
                            _count += 1
                            ; i = _internalArray.Length - 1
                        EndIf
                    EndIf
                EndTryLockGuard
            EndIf
        EndIf
    EndWhile

    ; Clean()
    LogObjectGlobal(akList, "Added items with last Index: " + i + " and Count: " + _count)
    return i
EndFunction

Int Function AddArray(Var[] akArray)
    If !_isInitialized
        return -1
    EndIf

    Int i = -1
    Int kI = 0
    While kI < akArray.Length
        Var kItem = akArray[kI]
        If TestType(kItem) 
            Int fI = Find(kItem)
            If fI < 0
                TryLockGuard _arrayGuard
                    i = _trackedIndex ; FindFirstEmpty()
                    If i > -1 && _trackedIndex <= _internalArray.Length
                        _internalArray[i] = kItem
                        _trackedIndex += 1
                        _count += 1
                    Else
                        If _internalArray.Length < _maxSize
                            _internalArray.Add(kItem, 1)
                            _trackedIndex += 1
                            _count += 1
                            ; i = _internalArray.Length - 1
                        EndIf
                    EndIf
                EndTryLockGuard
            EndIf
        EndIf
    EndWhile

    ; Clean()
    LogObjectGlobal(Self, "Added items with last Index: " + i + " and Count: " + _count)
    return i
EndFunction

Int Function Update(Var akItem)
    Int fI = Find(akItem)
    If fI < 0
        return Add(akItem)
    EndIf

    Int i = -1
    TryLockGuard _arrayGuard
        _internalArray[fI] = akItem
    EndTryLockGuard

    return fI
EndFunction

Int Function Remove(Var akItem)
    If !_isInitialized || !TestType(akItem)
        return -1
    EndIf

    Int i = -1
    TryLockGuard _arrayGuard
        i = Find(akItem)
        If i > -1
            _internalArray.Remove(i)
            _trackedIndex -= 1
            _count -= 1
        EndIf
    EndTryLockGuard

    ; Sort()
    LogObjectGlobal(akItem as ScriptObject, "Removed item with Index: " + i + " and Count: " + _count)
    return i
EndFunction

Int Function Find(Var akItem)
    If !_isInitialized || !TestType(akItem)
        return -1
    EndIf

    Int i = 0
    While i < _internalArray.Length
        If CompareItems(_internalArray[i], akItem)
            return i
        EndIf
        i += 1
    EndWhile

    return -1
EndFunction

Int[] Function FindAll(Var akItem)
    Int i = 0
    Int[] resArray = new Int[0]

    While i < Count
        If !IsNone(_internalArray[i])
            If CompareItems(_internalArray[i], akItem)
                resArray.Add(i, 1)
            EndIf
        EndIf

        i += 1
    EndWhile

    If resArray.Length > 0
        IntArrayClean(resArray)
    EndIf

    return resArray
EndFunction

Int Function FindStruct(String asVarName, Var akElement)
    return _FindStruct(asVarName, akElement)
;     Int i 
;     While i < _internalArray.Length
;         Var kItem = _internalArray[i]
;         If kItem is Struct
;             _internalArray.FindStruct("", akElement)
;         EndIf
;         i += 1
;     EndWhile
;     ; return _internalArray.FindStruct(asVarName, akElement)
EndFunction

Bool Function Contains(Var akItem)
    If Find(akItem) > -1
        return True
    EndIf

    return False
EndFunction

Int Function FindFirstEmpty()
    Int i = 0
    While i < _internalArray.Length
        If IsNone(_internalArray[i])
            return i
        EndIf

        i += 1
    EndWhile
    
    return -1
endFunction

Bool Function Sort(Int aiStartingIndex = 0)
    Bool bFirstNoneFound = False
    Int iFirstNonePos = aiStartingIndex
    While aiStartingIndex < _internalArray.Length
        If IsNone(_internalArray[aiStartingIndex])
            If bFirstNoneFound == False
                bFirstNoneFound = True
                iFirstNonePos = aiStartingIndex
                aiStartingIndex += 1
            Else
                aiStartingIndex += 1
            EndIf
        Else
            If bFirstNoneFound == True
                If !IsNone(_internalArray[aiStartingIndex])
                    TryLockGuard _arrayGuard
                        _internalArray[iFirstNonePos] = _internalArray[aiStartingIndex]
                        _internalArray[aiStartingIndex] = None
                    EndTryLockGuard

                    Sort(iFirstNonePos + 1)
                    return True
                Else
                    aiStartingIndex += 1
                EndIf
            Else
                aiStartingIndex += 1
            EndIf
        EndIf
    EndWhile

    return False
EndFunction

; Function Resize(Int amount)
;     Int i = 0
;     Int count = _internalArray.Length
;     Int newSize = _internalArray.Length + amount
;     Var[] resArray = new Var[newSize]
    
;     If newSize < count
;         count = newSize
;     EndIf

;     While i < count
;         resArray[i] = array[i]
;     EndWhile

;     TryLockGuard _arrayGuard
;         resArray = array
;     EndTryLockGuard
; EndFunction

Function Clean()
    Int i = 0
    ; Sort()

    TryLockGuard _arrayGuard
        While i < _internalArray.Length
            If IsNone(_internalArray[i])
                _internalArray.Remove(i)
            EndIf
        EndWhile
    EndTryLockGuard

    Sort()
EndFunction

Bool Function IsNone(Var akItem)
    If akItem is ScriptObject
        return HTG:UtilityExt.IsNone(akItem as ScriptObject) 
    EndIf

    return False
EndFunction

Bool Function TestType(Var akItem)
    If _internalArray.Length == 0 || _count == 0
        return True
    EndIf

    Var kArrayItem = _internalArray[0]
    If kArrayItem as Bool && akItem as Bool
        return True
    ElseIf kArrayItem as Int && akItem as Int
        return True
    ElseIf kArrayItem as Float && akItem as Float
        return True
    ; ElseIf kArrayItem as Array && akItem as Array
    ;     return akArrayItem as Array == akItem as Array
    ; ElseIf kArrayItem as Struct
    ElseIf kArrayItem as ScriptObject && akItem as ScriptObject
        return True
    EndIf

    return False
EndFunction

Bool Function CompareItems(Var akArrayItem, Var akItem)
    If !IsNone(akArrayItem) && !IsNone(akItem)
        If akArrayItem is Bool && akItem is Bool
            return akArrayItem as Bool == akItem as Bool
        ElseIf akArrayItem is Int && akItem is Int
            return akArrayItem as Int == akItem as Int
        ElseIf akArrayItem is Float && akItem is Float
            return akArrayItem as Float == akItem as Float
        ; ElseIf akArrayItem is Array && akItem is Array
        ;     return akArrayItem as Array == akItem as Array
        ; ElseIf akArrayItem is Struct
        ElseIf akArrayItem is ScriptObject && akItem is ScriptObject
            return akArrayItem as ScriptObject == akItem as ScriptObject
        EndIf
    EndIf
EndFunction

Var[] Function GetArray()
    return _internalArray
EndFunction

String Function ToString()
    String res = "HTG:Collection:List:" + GetFormEditorID() \
    + "\n\tHTG:Collection:List<" + ArrayType + ">" \
    + "\n\tHTG:Collection:List.Count:" + _count \
    + "\n\tHTG:Collection:List.Array:" + _internalArray \
    + "\n\tHTG:Collection:List.Cell:" + GetParentCell()

    return res
EndFunction

Bool Function WaitForInitialized()
    If _isInitialized
        return True
    EndIf
    
    Int currentCycle = 0
    Int maxCycle = 50
    Bool maxCycleHit
    While !maxCycleHit && !_isInitialized
        WaitExt(0.1)

        If currentCycle < maxCycle
            currentCycle += 1
        Else
            maxCycleHit = True
        EndIf
    EndWhile

    return _isInitialized
EndFunction

List Function _CreateList(SystemModuleInformation akMod, Int aiFormId = 0x00000817, String asModName = "HTG-System-Core", Int aiSize = 0) Global
    If HTG:UtilityExt.IsNone(akMod)
        return None
    EndIf

    String sModFile = asModName
    If akMod.IsCoreIntegrated
        sModFile = akMod.FileName
    EndIf

    Form kForm = CreateForm(aiFormId, sModFile)
    If !HTG:UtilityExt.IsNone(kForm)
        List kList = CreateReference(akMod, kform) as List
        If !HTG:UtilityExt.IsNone(kList)
            kList.Enable(False)
            kList.Initialize(aiSize)
            LogObjectGlobal(kList, kList.ToString())
            return kList
        EndIf
    EndIf

    return None
EndFunction

List Function _CreatedRegisteredList(SystemModuleInformation akMod, String asListType, Int aiSize = 0) Global
    FormList kRegistry = akMod.CollectionRegistry
    Form kForm
    Int i 
    While i < kRegistry.GetSize()
        kForm = kRegistry.GetAt(i)
        If !HTG:UtilityExt.IsNone(kForm)
            ScriptObject so = CreateReference(akMod, kform).CastAs(asListType)
            List kList = so as List
            If !HTG:UtilityExt.IsNone(kList)
                kList.Enable(False)
                kList.Initialize(aiSize)
                LogObjectGlobal(kList, kList.ToString())
                return kList
            EndIf
        EndIf

        i += 1
    EndWhile

    return None
EndFunction

Int Function _FindStruct(String asVarName, Var akElement)
    return -1
EndFunction