import os.path
import time

from loguru import logger
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.edge.options import Options
from selenium.webdriver.edge.service import Service
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

class ATrustLogin:
    def __init__(self, data_dir="data"):
        if not os.path.exists("data"):
            os.makedirs("data", exist_ok=True)

        # 配置Edge Driver选项
        self.options = Options()
        self.options.add_argument(f'user-data-dir="{data_dir}"')
        # options.add_argument("--start-maximized")
        self.options.add_argument("--ignore-certificate-errors")
        self.options.add_argument("--ignore-ssl-errors")

        # 初始化Edge Driver
        service = Service()
        self.driver = webdriver.Edge(service=service, options=self.options)
        self.wait = WebDriverWait(self.driver, 10)

    # 打开默认的portal地址并等待sangfor_main_auth_container出现
    def open_portal(self, portal_address):
        self.driver.get(portal_address)

        # 使用显式等待sangfor_main_auth_container元素出现
        self.wait.until(EC.presence_of_element_located((By.ID, "sangfor_main_auth_container")))
        self.wait.until(EC.presence_of_element_located((By.CLASS_NAME, "login-panel")))
        self.wait.until(lambda d: d.execute_script("return document.readyState") == "complete")

        time.sleep(1)

    def delay_input(self):
        time.sleep(1)

    # 递归查找具有指定placeholder的前两个非hidden类型的input框
    def find_input_fields(self, element, inputs_found=None):
        if inputs_found is None:
            inputs_found = []

        # 检查当前节点是否是符合条件的input框
        if element.tag_name == "input":
            placeholder = element.get_attribute("placeholder")
            input_type = element.get_attribute("type")
            # 确保input具有指定的placeholder，并且不是hidden类型
            if placeholder and ("账号" in placeholder or "account" in placeholder.lower() or "密码" in placeholder or "password" in placeholder.lower()) and input_type != "hidden":
                inputs_found.append(element)
                # 如果找到两个符合条件的input框就返回
                if len(inputs_found) == 2:
                    return inputs_found

        # 递归遍历所有子节点
        child_elements = element.find_elements(By.XPATH, "./*")
        for child in child_elements:
            result = self.find_input_fields(child, inputs_found)
            if result and len(result) == 2:
                return result
        return inputs_found

    # 输入用户名和密码
    def enter_credentials(self, username, password):
        # 找到包含ID=sangfor_main_auth_container的div
        main_auth_div = self.driver.find_element(By.ID, "sangfor_main_auth_container")

        # 递归查找前两个input框
        input_fields = self.find_input_fields(main_auth_div)

        if len(input_fields) >= 2:
            username_input = input_fields[0]
            password_input = input_fields[1]

            # 输入用户名和密码
            self.wait.until(EC.element_to_be_clickable(username_input)).click()
            self.delay_input()
            username_input.send_keys(username)

            self.wait.until(EC.element_to_be_clickable(password_input)).click()
            self.delay_input()
            password_input.send_keys(password)

            checkbox = main_auth_div.find_element(By.XPATH, "//input[@type='checkbox']")
            # 检查checkbox是否已经被选中
            if not checkbox.is_selected():
                self.delay_input()
                checkbox.click()  # 如果没有选中，就点击选中

            logger.debug("Filled username and password")
        else:
            logger.info("未找到用户名或密码输入框")

    # 查找并点击登录按钮
    def click_login_button(self):
        # 在div class=login-panel中寻找包含“登录”或“login”或“log in”的按钮
        login_panel = self.driver.find_element(By.CLASS_NAME, "login-panel")
        buttons = login_panel.find_elements(By.TAG_NAME, "button")

        for button in buttons:
            button_text = button.text.lower()
            if "登录" in button_text or "login" in button_text or "log in" in button_text:
                button.click()
                return
        logger.info("未找到符合条件的登录按钮")

    def login(self, portal_address, username, password, totp_key):
        self.open_portal(portal_address=portal_address)
        self.enter_credentials(username=username, password=password)
        self.delay_input()
        self.click_login_button()

    def close(self):
        self.driver.quit()

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        self.close()

def main(portal_address="https://61.150.47.8/portal/#/login", username="your_username", password="your_password", totp_key=None, data_dir="data"):
    logger.info("Opening Web Browser")

    # 创建ATrustLogin对象
    ATrustLogin(data_dir=data_dir).login(portal_address=portal_address, username=username, password=password, totp_key=totp_key)

if __name__ == "__main__":
    from fire import Fire
    Fire(main)
