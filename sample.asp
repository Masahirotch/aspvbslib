<% 
Option Explicit
%>
<!--#include file="./aspvbslib/adovbs.inc"-->
<!--#include file="./aspvbslib/aspvbslib-core.inc"-->
<!--#include file="./aspvbslib/aspvbslib-data.inc"-->
<!--#include file="./aspvbslib/aspvbslib-web.inc"-->
<%
' ViewModel�N���X
Class ViewModel
    '�^�C�g��
    Public title
    '�������X�g
    Public departments
    '�Ј����X�g
    Public employees
    '�I�𒆂̎Ј��ԍ�
    Public empno
    '�I�𒆂̕����ԍ�
    public deptno
    '�I�𒆂̎Ј�����
    Public empDetail
End Class

'RequestModel�N���X
Class RequestModel
    Public deptno
    Public empno
End Class
' RequestModel�N���X��PropNames�֐�(LoadRequest�֐��p�̒�`)
Function RequestModelPropNames
    RequestModelPropNames = Array("deptno", "empno")
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

'�����N���X
Class Dept
    '�����ԍ�
    Public deptno
    '������
    Public deptname
End Class

Dim vm
Call Main

Sub Main
    Set vm = New ViewModel

    Call LoadViewModel(vm)

    Call RenderHTML(vm)
End Sub

Function LoadViewModel(vm)
    '�^�C�g���̐ݒ�
    vm.title = "ArrayList��SqlQuery���g�����T���v��"

    '���N�G�X�g�̎擾
    Dim req: Set req = New RequestModel
    LoadRequest(req)

    vm.deptno = req.deptno
    If Len(vm.deptno) > 0 And ChkNum(vm.deptno) Then
        vm.deptno = CInt(vm.deptno)
    Else
        vm.deptno = ""
    End If

    vm.empno = req.empno
    If Len(vm.empno) > 0 And ChkNum(vm.empno) Then
        vm.empno = CInt(vm.empno)
    Else
        vm.empno = ""
    End If

    '�f�[�^�x�[�X�ڑ�
    Dim DbConn
    Set DbConn = Server.CreateObject("ADODB.Connection")
    Dim dbfilepath :dbfilepath = Server.MapPath("aspvbslib_sample.mdb")
    dim dbconnString :dbconnString = "Driver={Microsoft Access Driver (*.mdb)}; DBQ=" & dbfilepath & ";"
    DbConn.Open dbconnString

    '�������X�g�̎擾
    Set vm.departments = SqlQuery(DbConn, "Dept", "SELECT * FROM dept")
    if IsNullOrEmpty(vm.deptno) And vm.departments.Count > 0 Then
        vm.deptno = vm.departments(0).deptno
    End If
    
    '�Ј����X�g�̎擾�i�����w��j
    Dim cmd: Set cmd = Server.CreateObject("ADODB.Command")
    cmd.CommandText = "SELECT * FROM emp WHERE deptno=?"
    cmd.parameters.Append cmd.CreateParameter("@deptno", adInteger, adParamInput, , vm.deptno)
    Set vm.employees = SqlQuery(DbConn, "Emp", cmd)

    '�I�𒆂�empno�����݂��Ȃ���΁A���݂̃��X�g�̐擪��I������B
    If vm.employees.Where("item.empno = p", vm.empno).Count = 0 Then
        If vm.employees.Count > 0 Then
            vm.empno = vm.employees(0).empno
        Else
            vm.empno = ""
        End If
    End If

    '�I�𒆂̎Ј���񖾍ׂ�ݒ�
    If vm.empno = "" Then
        '�I������Ă��Ȃ���Ώ�����
        Set vm.empDetail = New Emp
    Else
        Set vm.empDetail = vm.employees.FindFirst("item.empno = p", vm.empno)(0)
    End If

    DbConn.Close
    Set DbConn = Nothing

End Function

Function RenderHTML(vm)
%>
<!doctype html>
<html lang="jp">
<head>
    <meta charset="shift-jis">
    <title><%=vm.title%></title>
    <meta name="description" content="Sample 01">
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous">  
    <style>
    </style>
</head>
<body>
<div class="container">
    <h4><%=vm.title%></h4>
    <form method="get">
        <div class="form-group">
            <label for="deptno">����</label>
            <select class="form-control" name="deptno" id="deptno" onchange="this.form.submit()">
                <% Dim dept: For Each dept In vm.departments.Items %>
                    <option value="<%=dept.deptno%>" <%=write_if("selected", dept.deptno=vm.deptno)%> data="<%=dept.deptno & ":" & vm.deptno & "(" & dept.deptno=vm.deptno & ")"%>"><%=dept.deptname%></option>
                <% Next %>
            </select>
        </div>

        <div class="form-group">
            <label for="empno">�Ј�</label>
            <select class="form-control" name="empno" id="empno" onchange="this.form.submit()">
                <% Dim emp: For Each emp In vm.employees.Items %>
                    <option value="<%=emp.empno%>" <%=write_if("selected", emp.empno=vm.empno)%>><%=emp.empname%></option>
                <% Next %>
            </select>
        </div>

        <div class="form-group">
            <label>�ڍ�</label>
            <div class="card p-3" style="width:18rem">
                <h5 class="card-title"><%=vm.empDetail.empname%></h5>
                <p class="card-text"><%=vm.empDetail.description%>
                </p>
            </div>
        </div>
    </form>
</div>
</body>
</html>
<%
End Function
%>