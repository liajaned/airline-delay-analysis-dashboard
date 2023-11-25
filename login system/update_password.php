
<?php
@include 'config.php';
session_start();

$error = [];

if(isset($_POST['submit'])) {
    $email = mysqli_real_escape_string($conn, $_POST['email']); // Assuming you're storing user's email in session

    $old_pass = md5($_POST['old_password']);
    $new_pass = md5($_POST['new_password']);
    $confirm_pass = md5($_POST['confirm_password']);

    // Fetch user's current password
    $select = "SELECT * FROM user_form WHERE email = '$email' && password = '$old_pass'";
    $result = mysqli_query($conn, $select);

    if(mysqli_num_rows($result) > 0) {
        if ($new_pass != $confirm_pass) {
            $error[] = 'New password and confirm password do not match!';
        } else {
            // Update user's password
            $update = "UPDATE user_form SET password = '$new_pass' WHERE email = '$email'";
            $update_result = mysqli_query($conn, $update);

            if ($update_result) {
                header('location: login_form.php'); // Redirect to login page after successful update
            } else {
                $error[] = 'Password update failed!';
            }
        }
    } else {
        $error[] = 'Incorrect old password!';
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
   <!-- Add necessary meta tags, title, stylesheets -->
   <link rel="stylesheet" href="css/style.css">
</head>
<body>
   
<div class="form-container">
   <form action="" method="post">
      <h3>Update Password</h3>
      <?php
      if(isset($error)){
         foreach($error as $error){
            echo '<span class="error-msg">'.$error.'</span>';
         };
      };
      ?>
      <input type="email" name="email" required placeholder="Enter email">
      <input type="password" name="old_password" required placeholder="Enter current password">
      <input type="password" name="new_password" required placeholder="Enter new password">
      <input type="password" name="confirm_password" required placeholder="Confirm new password">
      <input type="submit" name="submit" value="Update Password" class="form-btn">
      <p><a href="login_form.php">Back to Login</a></p>
   </form>
</div>

</body>
</html>
