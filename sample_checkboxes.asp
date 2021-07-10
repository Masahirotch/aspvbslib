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
    '�I�𒆂̕������X�g
    Public selectedDepartments
    '�I�𒆂̎Ј�no
    Public selectedEmp

End Class

'RequestModel�N���X
Class RequestModel
    '�I�𒆂̕���No�̃��X�g
    Public selectedDepartments

    '�I�𒆂̎Ј�No
    Public selectedEmp

    Sub Class_Initialize
        Set selectedDepartments = New ArrayList
        selectedDEpartments.ItemType = vbInteger    '���X�g�v�f�̌^��Integr�Ŏw�肷��iLoadRequest�ł��̌^�Ɏ����ϊ������j

        selectedEmp = CLng(0)   '�v���p�e�B�̌^��Long�Ŏw�肷��iLoadRequest�ł��̌^�Ɏ����ϊ������j
    End Sub
End Class
' RequestModel�N���X��PropNames�֐�(LoadRequest�֐��p�̒�`)
Function RequestModelPropNames
    RequestModelPropNames = Array("selectedDepartments", "selectedEmp")
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
    vm.title = "������checkbox�̒l���󂯎��T���v��"

    '���N�G�X�g�̎擾
    Dim req: Set req = New RequestModel
    LoadForm(req)

    Set vm.selectedDepartments = req.selectedDepartments
    vm.selectedEmp = req.selectedEmp

    '�f�[�^�x�[�X�ڑ�
    Dim DbConn
    Set DbConn = Server.CreateObject("ADODB.Connection")
    Dim dbfilepath :dbfilepath = Server.MapPath("aspvbslib_sample.mdb")
    dim dbconnString :dbconnString = "Driver={Microsoft Access Driver (*.mdb)}; DBQ=" & dbfilepath & ";"
    DbConn.Open dbconnString

    '�������X�g�̎擾
    Set vm.departments = SqlQuery(DbConn, "Dept", "SELECT * FROM dept")
    
    '�Ј����X�g�̎擾(�I�𒆂̕������X�g�i�����j�ɊY������Ј��̂�)
    Set vm.employees = SqlQuery(DbConn, "Emp", "SELECT * FROM emp").Where("InArray(item.deptno, p)", req.selectedDepartments.Items)

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
    <form name="frm" method="post">
        <div class="btn-group btn-group-toggle" data-toggle="buttons">
            <% Dim dept: For Each dept In vm.departments.Items %>
            <label class="btn btn-info <%=write_if("active", InArray(dept.deptno, vm.selectedDepartments.Items))%>">
                <input type="checkbox" name="selectedDepartments" value="<%=dept.deptno%>" <%=write_if("checked", InArray(dept.deptno, vm.selectedDepartments.Items))%> onchange="this.form.submit()" class="btn-check" autocomplete="off">
                <%=dept.deptname%>
            </label>
            <% Next %>
        </div>
        <input type="hidden" name="selectedEmp" value="" />

        <table class="table" style="width:500px">
            <thead style="<%=css_display(vm.employees.Count > 0)%>">
                <tr>
                    <th>empno</th>
                    <th>empname</th>
                    <th>deptname</th>
                </tr>
            </thead>
            <tbody>
                <% Dim emp: For Each emp In vm.employees.Items %>
                <tr class="<%=write_if("table-info", vm.selectedEmp = emp.empno)%>" onclick="document.frm.selectedEmp.value=<%=emp.empno%>; document.frm.submit()">
                    <td><%=emp.empno %></td>
                    <td><%=emp.empname %></td>
                    <td><%=vm.departments.FindFirst("item.deptno = p", emp.deptno).Map("item.deptname", Nothing).FirstOrDefault("") %></td>
                </tr>
                <% Next %>
            </tbody>
        </table>

    </form>

</div>
</body>
</html>
<%
End Function
%>