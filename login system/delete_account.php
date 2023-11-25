<?php
@include 'config.php';
session_start();

$error = [];

$error = '';

if (isset($_POST['delete'])) {
    $email = mysqli_real_escape_string($conn, $_POST['email']); // Assuming you're storing user's email in session

    $pass = md5($_POST['password']);
    

    $delete_query = "DELETE FROM user_form WHERE email = '$email' and password='$pass'";

    if (mysqli_query($conn, $delete_query)) {
        // Destroy the session and redirect after successful deletion
        session_destroy();
        header('Location: login_form.php'); // Redirect to login page after successful deletion
        exit();
    } else {
        $error = 'Error deleting account';
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
      <h3>Delete Account</h3>
      <?php
      if (!empty($error)) {
          echo '<span class="error-msg">'.$error.'</span>';
      };
      ?>
      <p>Are you sure you want to delete your account?</p>
      <input type="email" name="email" required placeholder="Enter email">
      <input type="password" name="password" required placeholder="Enter password">
      <input type="submit" name="delete" value="Yes, Delete Account" class="form-btn">
      <p><a href="login_form.php">Cancel</a></p>
   </form>
</div>

</body>
</html>
