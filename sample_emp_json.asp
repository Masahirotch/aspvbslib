<% 
Option Explicit
%>
<!--#include file="./aspvbslib/adovbs.inc"-->
<!--#include file="./aspvbslib/aspvbslib-core.inc"-->
<!--#include file="./aspvbslib/aspvbslib-data.inc"-->
<!--#include file="./aspvbslib/aspvbslib-web.inc"-->
<%
'RequestModel�N���X
Class RequestModel
    Public deptno
End Class
' RequestModel�N���X��PropNames�֐�(LoadRequest�֐��p�̒�`)
Function RequestModelPropNames()
    RequestModelPropNames = Array("deptno")
End Function

'ViewModel�N���X
Class ViewModel
    Public employees
End Class
' ViewModel�N���X��PropNames�֐�(JSONValue�֐��p�̒�`)
Function ViewModelPropNames()
    ViewModelPropNames = Array("employees")
End Function

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
' Emp�N���X��PropNames�֐�(JSONValue�֐��p�̒�`)
Function EmpPropNames()
    EmpPropNames = Array("empno", "empname", "deptno", "description")
End Function

Dim req, vm
Call Main

' ���C������
Sub Main
    Set req = New RequestModel
    Call LoadRequest(req)

    Set vm = New ViewModel
    Call LoadViewModel(vm, req)

    Call RenderJSON(vm)
End Sub

' ViewModel�̐ݒ�
Function LoadViewModel(vm, req)

    '�f�[�^�x�[�X�ڑ�
    Dim DbConn
    Set DbConn = Server.CreateObject("ADODB.Connection")
    Dim dbfilepath :dbfilepath = Server.MapPath("aspvbslib_sample.mdb")
    dim dbconnString :dbconnString = "Driver={Microsoft Access Driver (*.mdb)}; DBQ=" & dbfilepath & ";"
    DbConn.Open dbconnString

    '�Ј����X�g�̎擾�i�����w��j
    Dim cmd: Set cmd = Server.CreateObject("ADODB.Command")
    cmd.CommandText = "SELECT * FROM emp WHERE deptno=?"
    cmd.parameters.Append cmd.CreateParameter("@deptno", adInteger, adParamInput, , CInt(req.deptno))
    Set vm.employees = SqlQuery(DbConn, "Emp", cmd)

    DbConn.Close
    Set DbConn = Nothing

End Function

' ViewModel��JSON�`���ŕԋp
Function RenderJSON(vm)
    Response.Write JSONValue(vm)
End Function
%>