<!--#include file="./aspvbslib/adovbs.inc"-->
<!--#include file="./aspvbslib/aspvbslib-core.inc"-->
<!--#include file="./aspvbslib/aspvbslib-data.inc"-->
<!--#include file="./aspvbslib/aspvbslib-test.inc"-->
<%
'--------------------------------------------------------------------
' ASPVBSLib Data �̃��j�b�g�e�X�g
'--------------------------------------------------------------------

'�f�[�^�x�[�X�ڑ�
Dim DbConn
Set DbConn = Server.CreateObject("ADODB.Connection")
Dim dbfilepath :dbfilepath = Server.MapPath("aspvbslib_sample.mdb")
dim dbconnString :dbconnString = "Driver={Microsoft Access Driver (*.mdb)}; DBQ=" & dbfilepath & ";"
DbConn.Open dbconnString

'�Ј��N���X
Class Emp 
    '�Ј��ԍ�
    Public empno
    '�Ј���
    Public empname
    '�����ԍ�
    Public deptno
    '����
    Public description
End Class

'�����N���X
Class Dept
    '�����ԍ�
    Public deptno
    '������
    Public deptname
End Class

Class DeptProps
    '-------------------------------------------------------
    ' �ʏ�AProps�N���X�̓N���X���ȊO�͂��̂܂ܗ��p���A
    ' Prop�v���p�e�B�̃��[�U�[��`���̂ݑΏۃN���X�p�Ɏ�������B
    '-------------------------------------------------------
    '��obj, Target �͕ύX�s��
	private obj

	Public Property Get Target
		Set Target = obj
	End Property

	Public Property Set Target(newObj)
		Set obj = newObj
	End Property

	Public Property Get Prop(propName)
		Dim value

		Select Case propName
            '-- �������烆�[�U�[��`���� ------
			Case "deptno"
				value = obj.deptno
			Case "deptname"
				value = obj.deptname
            '-- �����܂� ---------------------
			Case Else
				value = Eval("obj." & propName)
		End Select
		Prop = value
	End Property

	Public Property Let Prop( propName, value )
		Select Case propName
            '-- �������烆�[�U�[��`���� ------
			Case "deptno"
				obj.deptno = value
			Case "deptname"
				obj.deptname = value
            '-- �����܂� ---------------------
			Case Else
				Execute("obj." & propName & " = value")
		End Select
	End Property

End Class

Sub TestMain()
	Dim test
	Set test = New UnitTest
	
	test.Add("SqlQueryTest")
	test.Add("DBSqlValueTest")

	test.RunTest
	test.ResultHtml

End Sub

Call TestMain()


Sub SqlQueryTest
	Dim list
	Set list = SqlQuery(DbConn, "Emp", "SELECT * FROM emp")

	'�S�Ă̗�
	AssertEquals list.Count, 12
	AssertEquals list.ItemClassName, "Emp"
	AssertEquals list.Item(0).empno, 1
	AssertEquals list.Item(0).empname, "�В��Ԏq"
	AssertEquals list.Item(0).deptno, 1
	AssertEquals TypeName(list.Item(0)), "Emp"

	'����Ȃ��v���p�e�B�L��
	Set list = SqlQuery(DbConn, "Emp", "SELECT empno, deptno, description FROM emp")
	AssertEquals list.Count, 12
	AssertEquals list.ItemClassName, "Emp"
	AssertEquals list.Item(0).empno, 1
	AssertEquals list.Item(0).empname, ""
	AssertEquals list.Item(0).deptno, 1
	AssertEquals TypeName(list.Item(0)), "Emp"

	'�}�b�s���O��ɑ��݂��Ȃ��v���p�e�B�L��
	Set list = SqlQuery(DbConn, "Emp", "SELECT empno, deptno AS departmentno, description FROM emp")
	AssertEquals list.Count, 12
	AssertEquals list.ItemClassName, "Emp"
	AssertEquals list.Item(0).empno, 1
	AssertEquals list.Item(0).empname, ""
	AssertEquals list.Item(0).deptno, ""
	AssertEquals TypeName(list.Item(0)), "Emp"

	'�l��Nothing�̗�
	Set list = SqlQuery(DbConn, "Emp", "SELECT empno, NULL AS empname, NULL AS deptno, description FROM emp")
	AssertEquals list.Count, 12
	AssertEquals list.ItemClassName, "Emp"
	AssertEquals list.Item(0).empno, 1
	AssertEquals list.Item(0).empname, Null
	AssertEquals list.Item(0).deptno, Null
	AssertEquals TypeName(list.Item(0)), "Emp"

	'Props�N���X���`Dept
	Set list = SqlQuery(DbConn, "Dept", "SELECT * FROM dept")
	AssertEquals list.Count, 6
	AssertEquals list.ItemClassName, "Dept"
	AssertEquals list.Item(0).deptno, 1
	AssertEquals list.Item(0).deptname, "�o�c��敔"
	AssertEquals TypeName(list.Item(0)), "Dept"

	'���ʂ�0���̃N�G��
	Set list = SqlQuery(DbConn, "Emp", "SELECT * FROM emp WHERE empno = 99999")
	AssertEquals list.Count,  0

End Sub

Sub DBSqlValueTest

	'���l�^
	AssertEquals DBSqlValue(CLng(123)), "123"
	AssertEquals DBSqlValue(CInt(123)), "123"
	AssertEquals DBSqlValue(CCur(123)), "123"
	AssertEquals DBSqlValue(CSng(123.456)), "123.456"
	AssertEquals DBSqlValue(CDbl(123.456)), "123.456"
	AssertEquals DBSqlValue(CDbl(123.456)), "123.456"

	'������^
	AssertEquals DBSqlValue(""), "''"
	AssertEquals DBSqlValue("abc"), "'abc'"

	'���t�^
	Dim dt
	dt = #12/31/2021 23:58:59#
	AssertEquals DBSqlValue(dt), "'2021-12-31 23:58:59'"
	dt = #12/31/2021#
	AssertEquals DBSqlValue(dt), "'2021-12-31 00:00:00'"

	'�_���^
	AssertEquals DBSqlValue(True), "True"
	AssertEquals DBSqlValue(False), "False"

	'Null Values
	Dim nullVal
	AssertEquals DBSqlValue(nullVal), "Null"
	nullVal = Null
	AssertEquals DBSqlValue(nullVal), "Null"

End Sub

%>